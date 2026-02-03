import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  // 2. MAKE CONTROLLER NULLABLE
  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Config
  static const LatLng _officeLocation = LatLng(
    11.55599257148443,
    104.91627071997854,
  );
  static const double _scanRangeMeters = 50;

  // State
  bool _isInRange = false;
  String _rangeStatusText = "កំពុងស្វែងរកទីតាំង...";
  Position? _lastKnownPosition;

  // Map Objects
  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  BitmapDescriptor? _userProfileIcon;
  final String _userProfileUrl = 'https://i.pravatar.cc/150?img=11';

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
    _setupOfficeMapObjects();
    _generateProfileMarker();
  }

  // 3. LISTEN FOR THEME CHANGES
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMapStyle(context);
  }

  // 4. FUNCTION TO APPLY DARK MODE STYLE
  void _updateMapStyle(BuildContext context) {
    if (mapController == null) return;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  final String _officeIconPath = AppImg.appIcon;

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

  Future<void> _setupOfficeMapObjects() async {
    final BitmapDescriptor customIcon = await getBytesFromAsset(
      AppImg.pinIcon,
      100,
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('office_center'),
          position: _officeLocation,
          infoWindow: const InfoWindow(title: "WorkSmart Office"),
          icon: customIcon,
          anchor: const Offset(0.5, 0.5),
        ),
      );

      _circles.add(
        Circle(
          circleId: const CircleId('office_zone'),
          center: _officeLocation,
          radius: _scanRangeMeters,
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          strokeColor: Theme.of(context).colorScheme.primary,
          strokeWidth: 2,
        ),
      );
    });
  }

  Future<void> _generateProfileMarker() async {
    try {
      final Uint8List? imageBytes = await _loadNetworkImageBytes(
        _userProfileUrl,
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
            _userProfileIcon = BitmapDescriptor.fromBytes(
              byteData.buffer.asUint8List(),
            );
          });
          _refreshUserMarker();
        }
      }
    } catch (e) {
      debugPrint("Error generating profile marker: $e");
    }
  }

  Future<Uint8List?> _loadNetworkImageBytes(String url) async {
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _initLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _rangeStatusText = "ត្រូវការការអនុញ្ញាតទីតាំង");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _rangeStatusText = "សូមបើកសិទ្ធិទីតាំងនៅក្នុងការកំណត់");
      return;
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateMapState(initialPosition);
    } catch (e) {
      debugPrint("Location service might be disabled or error: $e");
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) => _updateMapState(position),
          onError: (e) =>
              setState(() => _rangeStatusText = "កំពុងរង់ចាំទីតាំង..."),
        );
  }

  void _refreshUserMarker() {
    if (_lastKnownPosition != null) {
      _updateMapState(_lastKnownPosition!);
    }
  }

  Future<void> _openDirections() async {
    final lat = _officeLocation.latitude;
    final lng = _officeLocation.longitude;
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
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

  void _updateMapState(Position userPos) {
    _lastKnownPosition = userPos;

    double distance = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );

    bool inScanRange = distance <= _scanRangeMeters;

    Marker userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(userPos.latitude, userPos.longitude),
      icon:
          _userProfileIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      anchor: const Offset(0.5, 0.5),
      infoWindow: const InfoWindow(title: "Me"),
      zIndex: 2,
    );

    Set<Marker> newMarkers = Set.from(_markers);
    newMarkers.removeWhere((m) => m.markerId.value == 'user_location');
    newMarkers.add(userMarker);

    if (mounted) {
      setState(() {
        _isInRange = inScanRange;
        _rangeStatusText = inScanRange
            ? "អ្នកស្ថិតក្នុងបរិវេណការិយាល័យ"
            : "នៅឆ្ងាយ ${distance.toStringAsFixed(0)}m ពីការិយាល័យ";
        _markers = newMarkers;
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

  // Mock Data
  static const List<Map<String, dynamic>> employeeData = [
    {
      "name": "Dara",
      "role": "role_trainer",
      "score": "98%",
      "imgUrl": "https://i.pravatar.cc/150?img=2",
      "isTop": true,
    },
    {
      "name": "Vanda",
      "role": "role_ios",
      "score": "97%",
      "imgUrl": "https://i.pravatar.cc/150?img=9",
      "isTop": false,
    },
    {
      "name": "Vibol",
      "role": "role_designer",
      "score": "95%",
      "imgUrl": "https://i.pravatar.cc/150?img=3",
      "isTop": false,
    },
  ];

  static const List<Map<String, dynamic>> leaveData = [
    {
      "icon": Icons.beach_access,
      "label": "annual_leave",
      "amount": "12",
      "color": Colors.blue,
    },
    {
      "icon": Icons.sick_outlined,
      "label": "sick_leave",
      "amount": "5",
      "color": Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildStickyHeader(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildDateAndStatusRow().animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 20),
                    _buildTimeAttendanceSection(
                      context,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    _buildLiveMapCard(context)
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                    const SizedBox(height: 20),
                    _buildLeaveStatsSection(
                      context,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    _buildEmployeeSectionHeader(
                      context,
                    ).animate().fadeIn(delay: 700.ms),
                    _buildEmployeeList(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMapCard(BuildContext context) {
    String getFormattedDistance(String statusText) {
      if (!statusText.contains("m")) return "--";

      try {
        String rawMetric = statusText
            .split(" ")
            .firstWhere((s) => s.contains("m"), orElse: () => "");

        String numberString = rawMetric.replaceAll(RegExp(r'[^0-9.]'), '');

        if (numberString.isEmpty) return "--";

        double distance = double.parse(numberString);

        if (distance >= 1000) {
          return "${(distance / 1000).toStringAsFixed(2)} km";
        } else {
          return "${distance.toInt()} m";
        }
      } catch (e) {
        return "--";
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A4A4A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _officeLocation,
                      zoom: 16,
                    ),
                    onMapCreated: (c) => mapController = c,
                    markers: _markers,
                    circles: _circles,
                    myLocationEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isInRange
                                ? Theme.of(context).colorScheme.primary
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat()).fade().scale(),
                        const SizedBox(width: 6),
                        Text(
                          _isInRange
                              ? AppStrings.tr('office_zone')
                              : AppStrings.tr('outside_zone'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isInRange
                                ? Theme.of(context).colorScheme.primary
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('gps_status'),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isInRange
                                ? AppStrings.tr('ready_to_scan')
                                : AppStrings.tr('too_far'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isInRange
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.tr('get_directions'),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStrings.tr('distance'),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getFormattedDistance(_rangeStatusText),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _openDirections,
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_bike,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _isInRange
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                    boxShadow: _isInRange
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: ElevatedButton(
                    onPressed: _isInRange
                        ? () => {
                            Navigator.pushNamed(
                              context,
                              AppRoute.faceScanScreen,
                            ),
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: _isInRange ? Colors.white : Colors.grey[500],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.tr('scan_out'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _isInRange ? Colors.white : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pinned: true,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 80,
      titleSpacing: 20,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(_userProfileUrl),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr('greeting'),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
                Text(
                  "${AppStrings.tr('greet_pronoun_man')} វិនន័រ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoute.notificationScreen),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).iconTheme.color,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().shake(delay: 1.seconds, duration: 500.ms),
        ),
      ],
    );
  }

  Widget _buildDateAndStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "ថ្ងៃចន្ទ, ២៤ តុលា ២០២៣",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.tr('safety'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAttendanceSection(BuildContext context) {
    return Row(
      children: [
        _buildTimeCard(
          context,
          AppStrings.tr('check_in'),
          "08:00\nAM",
          Icons.login,
          false,
        ),
        const SizedBox(width: 10),
        _buildTimeCard(
          context,
          AppStrings.tr('check_out'),
          "--:--",
          Icons.logout,
          false,
        ),
        const SizedBox(width: 10),
        _buildTimeCard(
          context,
          AppStrings.tr('work_hours'),
          "4h 30m",
          Icons.access_time,
          true,
        ),
      ],
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 110,
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDark
                      ? Colors.white70
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              time,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveStatsSection(BuildContext context) {
    return Row(
      children: leaveData.map((data) {
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoute.leaveDatailScreen),
            child: Row(
              children: [
                Expanded(
                  child: _buildPremiumLeaveCard(
                    context,
                    data['icon'] as IconData,
                    AppStrings.tr(data['label']),
                    data['amount'],
                    data['color'] as Color,
                  ),
                ),
                if (data != leaveData.last) const SizedBox(width: 15),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumLeaveCard(
    BuildContext context,
    IconData icon,
    String label,
    String amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                "ថ្ងៃ",
                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: int.parse(amount) / 18,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.tr('employee_title'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoute.leaderboardScreen),
          child: Text(
            AppStrings.tr('view_all'),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeList(BuildContext context) {
    return Column(
      children: employeeData.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoute.leaderboardScreen),
          child:
              _buildEmployeeRow(
                    context,
                    entry.value['name'],
                    AppStrings.tr(entry.value['role']),
                    entry.value['score'],
                    entry.value['imgUrl'],
                    entry.value['isTop'],
                  )
                  .animate()
                  .fadeIn(delay: (800 + (entry.key * 100)).ms)
                  .slideX(begin: 0.1),
        );
      }).toList(),
    );
  }

  Widget _buildEmployeeRow(
    BuildContext context,
    String name,
    String role,
    String score,
    String imgUrl,
    bool isTop,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isTop ? Border.all(color: AppColors.secondary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(isTop ? 2 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isTop
                      ? Border.all(color: AppColors.secondary, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(imgUrl),
                ),
              ),
              if (isTop)
                Positioned(
                  top: -8,
                  right: -6,
                  child: Image.asset(AppImg.crown, width: 24, height: 24),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            score,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
