import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/map_styles.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/attendance_data.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/office_data.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/homepagescreen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class HomePageLogic extends State<HomePageScreen> {
  static String get _userLocationMarkerTitle => AppStrings.tr('map_marker_me');

  final RealtimeDataController _realtimeDataController =
      RealtimeDataController();

  // --- Data Models ---
  late UserProfile currentUser;
  late List<UserProfile> allEmployees;
  late String? loggedInUserId;

  List<Map<String, dynamic>> _userRecordsData = usersFinalData
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
  Map<String, dynamic> _officeConfigData = Map<String, dynamic>.from(
    officeMasterData,
  );
  StreamSubscription<List<Map<String, dynamic>>>? _userRecordsSubscription;
  StreamSubscription<Map<String, dynamic>?>? _officeConfigSubscription;
  String? _activeOfficeId;

  // --- State Variables ---
  GoogleMapController? mapController;
  StreamSubscription<Position>? positionStreamSubscription;

  late String currentFaceStatus;

  // --- Office Configuration  ---

  late LatLng officeLocation;
  late double scanRangeMeters;
  late String officeName;
  late String officeCheckInTime;
  late String officeCheckOutTime;
  late int lateBufferMinutes;

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
  late int checkOutScanAllowMinutes;
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
    _listenRealtimeData();

    initLocationTracking();
    setupOfficeMapObjects();
    generateProfileMarker();
  }

  void _loadData() {
    final userDataSource = _userRecordsData.isNotEmpty
        ? _userRecordsData
        : usersFinalData;

    final safeUserDataSource = userDataSource.isNotEmpty
        ? userDataSource
        : <Map<String, dynamic>>[defaultUserRecord];

    final currentUserData = safeUserDataSource.firstWhere(
      (user) => user['uid'] == loggedInUserId,
      orElse: () => safeUserDataSource.first,
    );
    currentUser = UserProfile.fromJson(currentUserData);
    final normalizedFaceStatus = currentUser.biometrics.faceStatus
        .trim()
        .toLowerCase();
    final bool hasFaceSamples =
        currentUser.biometrics.faceCount > 0 ||
        currentUser.biometrics.faceVectors.isNotEmpty;
    currentFaceStatus = normalizedFaceStatus.isEmpty
        ? 'uninitialized'
        : (normalizedFaceStatus == 'pending' && hasFaceSamples
              ? 'approved'
              : normalizedFaceStatus);

    allEmployees = safeUserDataSource
        .map((json) => UserProfile.fromJson(json))
        .toList();

    final geofence =
        (_officeConfigData['geofence'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final center =
        (geofence['center'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    officeLocation = LatLng(
      _toDouble(center['lat'], fallback: 11.572414392120761),
      _toDouble(center['lng'], fallback: 104.89332697012317),
    );
    scanRangeMeters = _toDouble(geofence['radius_meters'], fallback: 50);
    officeName = _officeConfigData['office_name'].toString();

    final Map<String, dynamic> policy = _asStringKeyMap(
      _officeConfigData['policy'],
    );
    officeCheckInTime = _readStringByKeys(policy, const [
      'check_in_start',
      'checkInStart',
    ], fallback: '09:00 AM');
    officeCheckOutTime = _readStringByKeys(policy, const [
      'check_out_end',
      'checkOutEnd',
    ], fallback: '06:00 PM');

    final dynamic rawAllowMinutes =
        _readByKeys(policy, const [
          'check_out_scan_allow_minutes',
          'checkOutScanAllowMinutes',
        ]) ??
        _readByKeys(_officeConfigData, const [
          'check_out_scan_allow_minutes',
          'checkOutScanAllowMinutes',
        ]);
    checkOutScanAllowMinutes = _parsePositiveInt(rawAllowMinutes, fallback: 30);

    final dynamic rawLateBufferMinutes =
        _readByKeys(policy, const [
          'late_buffer_minutes',
          'lateBufferMinutes',
        ]) ??
        _readByKeys(_officeConfigData, const [
          'late_buffer_minutes',
          'lateBufferMinutes',
        ]);
    lateBufferMinutes = _parsePositiveInt(rawLateBufferMinutes, fallback: 15);

    _syncScanStateFromAttendanceData();
  }

  Future<void> _listenRealtimeData() async {
    try {
      final users = await _realtimeDataController.fetchUserRecords();
      _userRecordsData = users;

      final office = await _realtimeDataController.fetchOfficeConnection(
        officeId: currentUser.officeId,
      );
      if (office != null) {
        _officeConfigData = office;
      }

      if (mounted) {
        setState(_loadData);
      }

      _subscribeOfficeConnection(currentUser.officeId);

      _userRecordsSubscription = _realtimeDataController
          .watchUserRecords()
          .listen((records) {
            if (!mounted) return;

            setState(() {
              _userRecordsData = records;
              _loadData();
            });

            _subscribeOfficeConnection(currentUser.officeId);
          });
    } catch (_) {
      return;
    }
  }

  void _subscribeOfficeConnection(String officeId) {
    final normalizedOfficeId = officeId.trim().isEmpty
        ? 'hq_phnom_penh_01'
        : officeId.trim();
    if (_activeOfficeId == normalizedOfficeId) {
      return;
    }

    _officeConfigSubscription?.cancel();
    _activeOfficeId = normalizedOfficeId;
    _officeConfigSubscription = _realtimeDataController
        .watchOfficeConnection(officeId: normalizedOfficeId)
        .listen((office) {
          if (!mounted || office == null) return;

          setState(() {
            _officeConfigData = office;
            _loadData();
          });
        });
  }

  void _syncScanStateFromAttendanceData() {
    final bool checkInDone = _isTypeCompleted('check_in');
    final bool checkOutDone = _isTypeCompleted('check_out');

    if (checkOutDone) {
      _stopCheckOutCooldown();
      selectedAttendanceScanType = 'check_out';
      hasMockScanSuccess = true;
      lastMockScanType = 'check_out';
      final String checkOutTime = (currentAttendance['check_out'] ?? '--:--')
          .toString();
      lastMockScanAt = _parse12hTime(checkOutTime);
      return;
    }

    if (checkInDone) {
      selectedAttendanceScanType = 'check_out';
      hasMockScanSuccess = false;
      lastMockScanType = 'check_in';
      lastMockScanAt = null;
      final DateTime? checkInAt = _getCompletedTypeTime('check_in');
      _syncCheckOutCooldownFromCheckIn(checkInAt);
      return;
    }

    _stopCheckOutCooldown();
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
    final policy =
        (_officeConfigData['policy'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

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
          lastMockScanAt = _getCompletedTypeTime(type);

          if (type == 'check_out') {
            _stopCheckOutCooldown();
          }
        } else {
          hasMockScanSuccess = false;
          lastMockScanAt = null;

          if (type == 'check_out') {
            final DateTime? checkInAt = _getCompletedTypeTime('check_in');
            _syncCheckOutCooldownFromCheckIn(checkInAt);
          }
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

  String get lateStartTimeLabel {
    final DateTime? lateThreshold = _getLateCheckInThreshold();
    if (lateThreshold == null) {
      return '--:--';
    }
    return _formatDateTimeTo12Hour(lateThreshold);
  }

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

  void _startCheckOutCooldown({required int initialSeconds}) {
    _checkOutCooldownTimer?.cancel();
    checkOutCooldownSeconds = initialSeconds;

    if (checkOutCooldownSeconds <= 0) {
      checkOutCooldownSeconds = 0;
      return;
    }

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
        checkOutCooldownSeconds = 0;
        timer.cancel();
      }
    });
  }

  void _stopCheckOutCooldown() {
    _checkOutCooldownTimer?.cancel();
    _checkOutCooldownTimer = null;
    checkOutCooldownSeconds = 0;
  }

  DateTime? _getCompletedTypeTime(String type) {
    final dynamic value = type == 'check_in'
        ? currentAttendance['check_in']
        : currentAttendance['check_out'];
    if (value is! String) return null;
    return _parse12hTime(value);
  }

  int _getRemainingCheckOutCooldownSeconds(DateTime checkInAt) {
    final DateTime? checkOutUnlockAt = _getCheckOutUnlockTime();
    if (checkOutUnlockAt == null) {
      return 0;
    }

    if (!checkOutUnlockAt.isAfter(checkInAt)) {
      return 0;
    }

    final int remaining = checkOutUnlockAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return 0;
    return remaining;
  }

  DateTime? _getCheckOutUnlockTime() {
    final DateTime? checkOutEnd = _parse12hTime(officeCheckOutTime);
    if (checkOutEnd == null) {
      return null;
    }

    return checkOutEnd.subtract(Duration(minutes: checkOutScanAllowMinutes));
  }

  DateTime? _getLateCheckInThreshold() {
    final DateTime? checkInStart = _parse12hTime(officeCheckInTime);
    if (checkInStart == null) {
      return null;
    }
    return checkInStart.add(Duration(minutes: lateBufferMinutes));
  }

  void _syncCheckOutCooldownFromCheckIn(DateTime? checkInAt) {
    if (checkInAt == null) {
      _stopCheckOutCooldown();
      return;
    }

    final int remainingSeconds = _getRemainingCheckOutCooldownSeconds(
      checkInAt,
    );
    if (remainingSeconds <= 0) {
      _stopCheckOutCooldown();
      return;
    }

    _startCheckOutCooldown(initialSeconds: remainingSeconds);
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
      final String normalized = value.trim();
      if (normalized.isEmpty || normalized == '--:--') return null;

      int hour;
      int minute;

      final List<String> parts = normalized.split(RegExp(r'\s+'));
      if (parts.length == 2) {
        final List<String> hm = parts[0].split(':');
        if (hm.length != 2) return null;

        hour = int.parse(hm[0]);
        minute = int.parse(hm[1]);
        final String period = parts[1].toUpperCase();

        if (period != 'AM' && period != 'PM') return null;
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      } else {
        final List<String> hm = normalized.split(':');
        if (hm.length != 2) return null;

        hour = int.parse(hm[0]);
        minute = int.parse(hm[1]);
      }

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  String _formatDateTimeTo12Hour(DateTime value) {
    final int hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String minute = value.minute.toString().padLeft(2, '0');
    final String period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMapStyle(context);
  }

  @override
  void dispose() {
    _checkOutCooldownTimer?.cancel();
    _userRecordsSubscription?.cancel();
    _officeConfigSubscription?.cancel();
    positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  double _toDouble(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> _asStringKeyMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }

  dynamic _readByKeys(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key)) {
        return source[key];
      }
    }
    return null;
  }

  String _readStringByKeys(
    Map<String, dynamic> source,
    List<String> keys, {
    required String fallback,
  }) {
    final dynamic raw = _readByKeys(source, keys);
    final String parsed = raw?.toString().trim() ?? '';
    return parsed.isNotEmpty ? parsed : fallback;
  }

  int _parsePositiveInt(dynamic raw, {required int fallback}) {
    final int parsed = raw is num
        ? raw.toInt()
        : int.tryParse(raw?.toString() ?? '') ?? fallback;
    return parsed > 0 ? parsed : fallback;
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
      const double size = 120.0;
      const double radius = size / 2;
      const Color markerColor = Color(0xFF4285F4);

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final Paint fillPaint = Paint()
        ..color = markerColor
        ..style = PaintingStyle.fill;
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;

      canvas.drawCircle(const Offset(radius, radius), radius - 3, fillPaint);
      canvas.drawCircle(const Offset(radius, radius), radius - 3, borderPaint);

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: _userLocationMarkerTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final Offset textOffset = Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      );
      textPainter.paint(canvas, textOffset);

      final ui.Image markerImage = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await markerImage.toByteData(
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
    } catch (e) {
      debugPrint("Error generating user marker: $e");
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
      infoWindow: InfoWindow(title: _userLocationMarkerTitle),
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

  void markMockScanSuccess() {
    if (mounted) {
      setState(() {
        final String scannedType = selectedAttendanceScanType;
        lastMockScanType = scannedType;

        lastMockScanAt = _getCompletedTypeTime(scannedType);

        final bool isCompleted = _isTypeCompleted(scannedType);
        attendanceScanStatus[scannedType] = isCompleted;
        attendanceScanSuccessAt[scannedType] = lastMockScanAt;

        if (scannedType == 'check_in' &&
            !(attendanceScanStatus['check_out'] ?? false)) {
          selectedAttendanceScanType = 'check_out';
          hasMockScanSuccess = false;
          lastMockScanAt = null;
          final DateTime? checkInAt = _getCompletedTypeTime('check_in');
          _syncCheckOutCooldownFromCheckIn(checkInAt);
        } else {
          hasMockScanSuccess = isCompleted;

          if (scannedType == 'check_out' && isCompleted) {
            _stopCheckOutCooldown();
          }
        }
      });
    }
  }

  void applyDatabaseAttendanceScan(Map<String, dynamic> savedRecord) {
    final Map<String, dynamic> normalizedRecord = Map<String, dynamic>.from(
      savedRecord,
    );
    final String uid = (normalizedRecord['uid'] ?? currentUser.uid)
        .toString()
        .trim();
    final String dateKey =
        (normalizedRecord['date'] ?? currentAttendance['date'])
            .toString()
            .trim();

    if (uid.isEmpty || dateKey.isEmpty) {
      return;
    }

    final int existingIndex = attendanceRecords.indexWhere(
      (record) =>
          record['uid']?.toString() == uid &&
          record['date']?.toString() == dateKey,
    );

    final Map<String, dynamic> mergedRecord = {
      if (existingIndex >= 0) ...attendanceRecords[existingIndex],
      ...normalizedRecord,
      'uid': uid,
      'date': dateKey,
    };

    if (existingIndex >= 0) {
      attendanceRecords[existingIndex] = mergedRecord;
    } else {
      attendanceRecords.add(mergedRecord);
    }

    if (!mounted) return;

    setState(() {
      overrideCheckInTime = null;
      overrideCheckOutTime = null;
      overrideTotalHours = null;
      _syncScanStateFromAttendanceData();
    });
  }

  void resetMockScanSuccess() {
    if (mounted) {
      setState(() {
        hasMockScanSuccess = false;
      });
    }
  }
}
