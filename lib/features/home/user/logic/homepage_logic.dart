import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/map_styles.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/leave_attendance.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/officeMasterData.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/homepage_screens/homepagescreen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart'; // Ensure correct path for UserProfile
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class HomePageLogic extends State<HomePageScreen> {
  // --- Data Models ---
  late UserProfile currentUser;
  late List<UserProfile> allEmployees;
  late String? loggedInUserId;

  // --- State Variables ---
  GoogleMapController? mapController;
  StreamSubscription<Position>? positionStreamSubscription;

  // Note: faceStatus is now derived from currentUser.biometrics.faceStatus
  // We keep a local variable if we need to update it dynamically before a refresh
  late String currentFaceStatus;

  // --- Office Configuration (Loaded from officeMasterData) ---
  late final LatLng officeLocation;
  late final double scanRangeMeters;
  late final String officeName;
  late final String officeCheckInTime;
  late final String officeCheckOutTime;

  // --- UI State Tracking ---
  bool isInRange = false;
  String rangeStatusText = AppStrings.tr('finding_location');
  Position? lastKnownPosition;

  // --- Map Objects ---
  Set<Marker> markers = {};
  final Set<Circle> circles = {};
  BitmapDescriptor? userProfileIcon;

  @override
  void initState() {
    super.initState();
    // Get logged-in user ID from login data
    loggedInUserId = widget.loginData?['uid'];
    _loadData();

    // Initialize services
    initLocationTracking();
    setupOfficeMapObjects();
    generateProfileMarker();
  }

  void _loadData() {
    // 1. Load Current User from login data
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == loggedInUserId,
      orElse: () => usersFinalData[0],
    );
    currentUser = UserProfile.fromJson(currentUserData);
    currentFaceStatus = currentUser.biometrics.faceStatus;

    // 2. Load All Employees for Leaderboard
    allEmployees = usersFinalData
        .map((json) => UserProfile.fromJson(json))
        .toList();

    // 3. Load Office Config
    final geofence = officeMasterData['geofence'];
    final center = geofence['center'];
    officeLocation = LatLng(center['lat'], center['lng']);
    scanRangeMeters = (geofence['radius_meters'] as num).toDouble();
    officeName = officeMasterData['office_name'];

    // 4. Load Office Policy Times
    final policy = officeMasterData['policy'] ?? {};
    officeCheckInTime = policy['check_in_start'] ?? '08:00 AM';
    officeCheckOutTime = policy['check_out_end'] ?? '05:00 PM';
  }

  // --- Getters for UI Consumption ---

  List<Map<String, dynamic>> get employeeListDisplayData {
    final sortedEmployees = List<UserProfile>.from(allEmployees)
      ..sort((a, b) {
        final scoreA = a.achievements.performanceScore;
        final scoreB = b.achievements.performanceScore;
        return scoreB.compareTo(scoreA);
      });

    return List.generate(sortedEmployees.length, (index) {
      final user = sortedEmployees[index];
      final rank = index + 1;

      return {
        "name": user.displayName,
        "role": user.roleTitle,
        "score":
            "${user.achievements.performanceScore} ${AppStrings.tr('points_label')}",
        "imgUrl": user.profileUrl,
        "isTop": rank < 2,
      };
    });
  }

  // Map Policy limits to UI cards with progress bar for used leaves
  // inside homepage_logic.dart

  List<Map<String, dynamic>> get leaveStatisticsData {
    final policy = officeMasterData['policy'] ?? {};

    // 1. Get Limits from Policy
    final int annualLimit =
        (policy['annual_leave_limit'] as num?)?.toInt() ?? 0;
    final int sickLimit = (policy['sick_leave_limit'] as num?)?.toInt() ?? 0;

    // 2. Calculate "Taken" days from the User's actual records
    // Filter by type AND status must be 'approved'
    int calculateTaken(String type) {
      return currentUser.leaveRecords
          .where((record) => record.type == type && record.status == 'approved')
          .fold(0, (sum, record) => sum + record.durationInDays);
    }

    final int annualTaken = calculateTaken('annual_leave');
    final int sickTaken = calculateTaken('sick_leave');

    // 3. Calculate Progress (Used / Limit)
    final annualProgress = annualLimit > 0
        ? (annualTaken / annualLimit).clamp(0.0, 1.0)
        : 0.0;
    final sickProgress = sickLimit > 0
        ? (sickTaken / sickLimit).clamp(0.0, 1.0)
        : 0.0;

    return [
      {
        "icon": Icons.beach_access,
        "label": "annual_leave",
        "amount": "$annualLimit",
        "color": Colors.blue,
        "progress": annualProgress,
        "used": annualTaken,
        "remaining": (annualLimit - annualTaken).clamp(0, annualLimit),
      },
      {
        "icon": Icons.sick_outlined,
        "label": "sick_leave",
        "amount": "$sickLimit",
        "color": Colors.purple,
        "progress": sickProgress,
        "used": sickTaken,
        "remaining": (sickLimit - sickTaken).clamp(0, sickLimit),
      },
    ];
  }

  // Get formatted attendance data for today
  Map<String, dynamic> get currentAttendance {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Get office policy for default times
    final policy = officeMasterData['policy'] ?? {};
    final defaultCheckIn = policy['check_in_start'] ?? "08:00 AM";
    final defaultCheckOut = policy['check_out_end'] ?? "05:00 PM";

    // Find today's attendance record for current user
    try {
      final todayRecord = attendanceRecords.firstWhere(
        (record) =>
            record['uid'] == currentUser.uid && record['date'] == todayStr,
      );

      return {
        'date': todayStr,
        'check_in': todayRecord['check_in'] ?? defaultCheckIn,
        'check_out': todayRecord['check_out'] ?? defaultCheckOut,
        'total_hours': todayRecord['total_hours'] ?? 0.0,
        'status': todayRecord['status'] ?? 'absent',
      };
    } catch (e) {
      // No record for today, return default structure
      return {
        'date': todayStr,
        'check_in': '--:--',
        'check_out': '--:--',
        'total_hours': 0.0,
        'status': 'not_checked_in',
      };
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMapStyle(context);
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  void updateMapStyle(BuildContext context) {
    if (mapController == null) return;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mapController!.setMapStyle(isDarkMode ? MapStyles.dark : null);
  }

  Future<BitmapDescriptor> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return BitmapDescriptor.fromBytes(
      (await fi.image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List(),
    );
  }

  Future<void> setupOfficeMapObjects() async {
    // Ensure assets exist or handle error
    try {
      final BitmapDescriptor customIcon = await getBytesFromAsset(
        AppImg.pinIcon,
        100,
      );
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('office_center'),
            position: officeLocation,
            infoWindow: InfoWindow(title: officeName),
            icon: customIcon,
            anchor: const Offset(0.5, 0.5),
          ),
        );
        circles.add(
          Circle(
            circleId: const CircleId('office_zone'),
            center: officeLocation,
            radius: scanRangeMeters,
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            strokeColor: Theme.of(context).colorScheme.primary,
            strokeWidth: 2,
          ),
        );
      });
    } catch (e) {
      debugPrint("Error loading map pin asset: $e");
    }
  }

  Future<void> generateProfileMarker() async {
    try {
      final Uint8List? imageBytes = await loadNetworkImageBytes(
        currentUser.profileUrl,
      );
      if (imageBytes != null) {
        final ui.Codec codec = await ui.instantiateImageCodec(
          imageBytes,
          targetHeight: 120,
          targetWidth: 120,
        );
        final ui.FrameInfo fi = await codec.getNextFrame();
        final ui.Image image = fi.image;
        final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(pictureRecorder);
        const double size = 120.0;
        const double radius = size / 2;
        final Paint borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(const Offset(radius, radius), radius, borderPaint);
        final Path clipPath = Path()
          ..addOval(
            Rect.fromCircle(
              center: const Offset(radius, radius),
              radius: radius - 6,
            ),
          );
        canvas.clipPath(clipPath);
        paintImage(
          canvas: canvas,
          rect: const Rect.fromLTWH(6, 6, size - 12, size - 12),
          image: image,
          fit: BoxFit.cover,
        );
        final ui.Image recordedImage = await pictureRecorder
            .endRecording()
            .toImage(size.toInt(), size.toInt());
        final ByteData? byteData = await recordedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          setState(() {
            userProfileIcon = BitmapDescriptor.fromBytes(
              byteData.buffer.asUint8List(),
            );
          });
          refreshUserMarker();
        }
      }
    } catch (e) {
      debugPrint("Error generating profile marker: $e");
    }
  }

  Future<Uint8List?> loadNetworkImageBytes(String url) async {
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> initLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => rangeStatusText = AppStrings.tr('perm_needed'));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => rangeStatusText = AppStrings.tr('enable_loc_settings'));
      return;
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      updateMapState(initialPosition);
    } catch (e) {
      debugPrint("Location service error: $e");
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) => updateMapState(position),
          onError: (e) =>
              setState(() => rangeStatusText = AppStrings.tr('waiting_loc')),
        );
  }

  void refreshUserMarker() {
    if (lastKnownPosition != null) {
      updateMapState(lastKnownPosition!);
    }
  }

  Future<void> openDirections() async {
    final lat = officeLocation.latitude;
    final lng = officeLocation.longitude;
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  void updateMapState(Position userPos) {
    lastKnownPosition = userPos;

    if (userPos.isMocked) {
      if (mounted) {
        setState(() {
          isInRange = false;
          rangeStatusText = AppStrings.tr('mock_gps_label');
          markers = {};
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.tr('mock_gps_warning'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    double distance = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      officeLocation.latitude,
      officeLocation.longitude,
    );

    bool inScanRange = distance <= scanRangeMeters;

    Marker userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(userPos.latitude, userPos.longitude),
      icon:
          userProfileIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      anchor: const Offset(0.5, 0.5),
      infoWindow: const InfoWindow(title: "Me"),
      zIndex: 2,
    );

    Set<Marker> newMarkers = Set.from(markers);
    newMarkers.removeWhere((m) => m.markerId.value == 'user_location');
    newMarkers.add(userMarker);

    if (mounted) {
      setState(() {
        isInRange = inScanRange;
        rangeStatusText = inScanRange
            ? AppStrings.tr('in_office_area')
            : "${AppStrings.tr('far_from_office')} ${distance.toStringAsFixed(0)}m";
        markers = newMarkers;
      });

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userPos.latitude, userPos.longitude),
            zoom: 18,
            tilt: 0,
          ),
        ),
      );
    }
  }

  // --- Face Status Management ---
  /// Updates the face status (3 states: not_registered, pending, approved)
  void updateFaceStatus(String newStatus) {
    if (mounted) {
      setState(() {
        currentFaceStatus = newStatus;
      });
    }
  }

  /// Handles face registration completion
  /// Sets status to 'pending' immediately, then 'approved' after 5 seconds
  void handleFaceRegistrationComplete() {
    updateFaceStatus('pending');

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        updateFaceStatus('approved');
      }
    });
  }
}