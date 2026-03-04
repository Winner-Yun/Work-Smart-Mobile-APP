import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/map_styles.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/officeMasterData.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/homepagescreen.dart';
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
  bool hasMockScanSuccess = false;
  DateTime? lastMockScanAt;
  String selectedAttendanceScanType = 'check_in';
  String lastMockScanType = 'check_in';
  String? overrideCheckInTime;
  String? overrideCheckOutTime;
  double? overrideTotalHours;
  final Map<String, bool> attendanceScanStatus = {
    'check_in': false,
    'check_out': false,
  };
  final Map<String, DateTime?> attendanceScanSuccessAt = {
    'check_in': null,
    'check_out': null,
  };
  int checkOutCooldownSeconds = 0;
  Timer? _checkOutCooldownTimer;

  // --- Map Objects ---
  Set<Marker> markers = {};
  final Set<Circle> circles = {};
  BitmapDescriptor? userProfileIcon;

  @override
  void initState() {
    super.initState();
    loggedInUserId = widget.loginData?['uid'];
    _loadData();

    initLocationTracking();
    setupOfficeMapObjects();
    generateProfileMarker();
  }

  void _loadData() {
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == loggedInUserId,
      orElse: () => usersFinalData[0],
    );
    currentUser = UserProfile.fromJson(currentUserData);
    currentFaceStatus = currentUser.biometrics.faceStatus;

    allEmployees = usersFinalData
        .map((json) => UserProfile.fromJson(json))
        .toList();

    final geofence = officeMasterData['geofence'];
    final center = geofence['center'];
    officeLocation = LatLng(center['lat'], center['lng']);
    scanRangeMeters = (geofence['radius_meters'] as num).toDouble();
    officeName = officeMasterData['office_name'];

    final policy = officeMasterData['policy'] ?? {};
    officeCheckInTime = policy['check_in_start'] ?? '08:00 AM';
    officeCheckOutTime = policy['check_out_end'] ?? '05:00 PM';

    _syncScanStateFromAttendanceData();
  }

  void _syncScanStateFromAttendanceData() {
    final bool checkInDone = _isTypeCompleted('check_in');
    final bool checkOutDone = _isTypeCompleted('check_out');

    if (checkInDone && !checkOutDone) {
      selectedAttendanceScanType = 'check_out';
      hasMockScanSuccess = false;
      lastMockScanAt = null;
      return;
    }

    if (checkOutDone) {
      selectedAttendanceScanType = 'check_out';
      hasMockScanSuccess = true;
      lastMockScanType = 'check_out';
      lastMockScanAt = _parse12hTime(currentAttendance['check_out'] as String);
      return;
    }

    if (checkInDone) {
      selectedAttendanceScanType = 'check_in';
      hasMockScanSuccess = true;
      lastMockScanType = 'check_in';
      lastMockScanAt = _parse12hTime(currentAttendance['check_in'] as String);
      return;
    }

    selectedAttendanceScanType = 'check_in';
    hasMockScanSuccess = false;
    lastMockScanAt = null;
  }

  // --- Getters for UI Consumption ---

  String _getDisplayLastName(String? fullName) {
    if (fullName == null) return '';
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    return parts.last;
  }

  String get currentUserDisplayName =>
      _getDisplayLastName(currentUser.displayName);

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
        "name": _getDisplayLastName(user.displayName),
        "role": user.roleTitle,
        "score":
            "${user.achievements.performanceScore} ${AppStrings.tr('points_label')}",
        "imgUrl": user.profileUrl,
        "isTop": rank < 2,
      };
    });
  }

  // Map Policy limits to UI cards with progress bar for used leaves

  List<Map<String, dynamic>> get leaveStatisticsData {
    final policy = officeMasterData['policy'] ?? {};

    final int annualLimit =
        (policy['annual_leave_limit'] as num?)?.toInt() ?? 0;
    final int sickLimit = (policy['sick_leave_limit'] as num?)?.toInt() ?? 0;

    int calculateTaken(String type) {
      return currentUser.leaveRecords
          .where((record) => record.type == type && record.status == 'approved')
          .fold(0, (sum, record) => sum + record.durationInDays);
    }

    final int annualTaken = calculateTaken('annual_leave');
    final int sickTaken = calculateTaken('sick_leave');

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

    try {
      final todayRecord = attendanceRecords.firstWhere(
        (record) =>
            record['uid'] == currentUser.uid && record['date'] == todayStr,
      );

      final Map<String, dynamic> attendance = {
        'date': todayStr,
        'check_in': todayRecord['check_in'] ?? '--:--',
        'check_out': todayRecord['check_out'] ?? '--:--',
        'total_hours': todayRecord['total_hours'] ?? 0.0,
        'status': todayRecord['status'] ?? 'absent',
      };
      if (overrideCheckInTime != null) {
        attendance['check_in'] = overrideCheckInTime;
      }
      if (overrideCheckOutTime != null) {
        attendance['check_out'] = overrideCheckOutTime;
      }
      if (overrideTotalHours != null) {
        attendance['total_hours'] = overrideTotalHours;
      }
      return attendance;
    } catch (e) {
      final Map<String, dynamic> attendance = {
        'date': todayStr,
        'check_in': '--:--',
        'check_out': '--:--',
        'total_hours': 0.0,
        'status': 'not_checked_in',
      };
      if (overrideCheckInTime != null) {
        attendance['check_in'] = overrideCheckInTime;
      }
      if (overrideCheckOutTime != null) {
        attendance['check_out'] = overrideCheckOutTime;
      }
      if (overrideTotalHours != null) {
        attendance['total_hours'] = overrideTotalHours;
      }
      return attendance;
    }
  }

  void selectAttendanceScanType(String type) {
    if (type != 'check_in' && type != 'check_out') return;

    if (type == 'check_out' && !_isTypeCompleted('check_in')) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
          title: Text(
            AppStrings.tr('check_out_requires_check_in'),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppStrings.tr('check_out_requires_check_in_desc'),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppStrings.tr('understood')),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        selectedAttendanceScanType = type;
        final bool alreadyScanned = _isTypeCompleted(type);
        if (alreadyScanned) {
          hasMockScanSuccess = true;
          lastMockScanType = type;
          lastMockScanAt = attendanceScanSuccessAt[type];
        } else {
          hasMockScanSuccess = false;
          lastMockScanAt = null;
        }
      });
    }
  }

  bool get isSelectedScanCompleted =>
      _isTypeCompleted(selectedAttendanceScanType);

  bool get isScanCooldownActive =>
      selectedAttendanceScanType == 'check_out' && checkOutCooldownSeconds > 0;

  String get selectedAttendanceScanLabel =>
      selectedAttendanceScanType == 'check_in'
      ? AppStrings.tr('check_in')
      : AppStrings.tr('check_out');

  String get lastAttendanceScanLabel => lastMockScanType == 'check_in'
      ? AppStrings.tr('check_in')
      : AppStrings.tr('check_out');

  String get selectedAttendanceActionText => isScanCooldownActive
      ? '${AppStrings.tr('wait')} ${_formatCooldownDuration(checkOutCooldownSeconds)}'
      : isSelectedScanCompleted
      ? '$selectedAttendanceScanLabel ${AppStrings.tr('scan_success')}'
      : selectedAttendanceScanType == 'check_in'
      ? '${AppStrings.tr('ready_to_scan')} ${AppStrings.tr('check_in')}'
      : '${AppStrings.tr('ready_to_scan')} ${AppStrings.tr('check_out')}';

  bool _isTypeCompleted(String type) {
    final attendance = currentAttendance;
    final value = type == 'check_in'
        ? attendance['check_in']
        : attendance['check_out'];

    if (value == null) return false;
    if (value is! String) return false;

    final normalized = value.trim();
    return normalized.isNotEmpty && normalized != '--:--';
  }

  String _formatCooldownDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final List<String> parts = [];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0) parts.add('${seconds}s');

    return parts.isNotEmpty ? parts.join(' ') : '0s';
  }

  void _startCheckOutCooldown() {
    _checkOutCooldownTimer?.cancel();
    checkOutCooldownSeconds = 3600; // for set cooldown duration

    _checkOutCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (checkOutCooldownSeconds > 0) {
          checkOutCooldownSeconds--;
        }
      });

      if (checkOutCooldownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void applyMockAttendanceScan() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = "$hour12:$minute $period";

    if (mounted) {
      setState(() {
        if (selectedAttendanceScanType == 'check_in') {
          overrideCheckInTime = formattedTime;
        } else {
          overrideCheckOutTime = formattedTime;
        }

        final String? effectiveCheckIn = _resolveEffectiveTime('check_in');
        final String? effectiveCheckOut = _resolveEffectiveTime('check_out');
        overrideTotalHours = _calculateWorkingHours(
          effectiveCheckIn,
          effectiveCheckOut,
        );
      });
    }
  }

  String? _resolveEffectiveTime(String type) {
    if (type == 'check_in') {
      if (overrideCheckInTime != null) return overrideCheckInTime;
      final dynamic checkIn = currentAttendance['check_in'];
      if (checkIn is String && _parse12hTime(checkIn) != null) return checkIn;
      return null;
    }

    if (type == 'check_out') {
      if (overrideCheckOutTime != null) return overrideCheckOutTime;
      final dynamic checkOut = currentAttendance['check_out'];
      if (checkOut is String && _parse12hTime(checkOut) != null) {
        return checkOut;
      }
      return null;
    }

    return null;
  }

  double? _calculateWorkingHours(String? checkIn, String? checkOut) {
    if (checkIn == null || checkOut == null) return null;

    final DateTime? inTime = _parse12hTime(checkIn);
    final DateTime? outTime = _parse12hTime(checkOut);
    if (inTime == null || outTime == null) return null;

    Duration diff = outTime.difference(inTime);
    if (diff.isNegative) {
      diff = const Duration();
    }

    return double.parse((diff.inMinutes / 60).toStringAsFixed(1));
  }

  DateTime? _parse12hTime(String value) {
    try {
      final parts = value.trim().split(' ');
      if (parts.length != 2) return null;

      final hm = parts[0].split(':');
      if (hm.length != 2) return null;

      int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      final String period = parts[1].toUpperCase();

      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMapStyle(context);
  }

  @override
  void dispose() {
    _checkOutCooldownTimer?.cancel();
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

  void markMockScanSuccess() {
    if (mounted) {
      setState(() {
        final String scannedType = selectedAttendanceScanType;
        final now = DateTime.now();
        lastMockScanAt = now;
        lastMockScanType = scannedType;
        attendanceScanStatus[scannedType] = true;
        attendanceScanSuccessAt[scannedType] = now;

        if (scannedType == 'check_in' &&
            !(attendanceScanStatus['check_out'] ?? false)) {
          selectedAttendanceScanType = 'check_out';
          hasMockScanSuccess = false;
          lastMockScanAt = null;
          _startCheckOutCooldown();
        } else {
          hasMockScanSuccess = true;
        }
      });
    }
  }

  void resetMockScanSuccess() {
    if (mounted) {
      setState(() {
        hasMockScanSuccess = false;
      });
    }
  }
}
