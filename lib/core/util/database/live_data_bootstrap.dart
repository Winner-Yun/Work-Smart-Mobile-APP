import 'dart:async';

import 'package:flutter_worksmart_mobile_app/core/util/database/attendance_data.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/office_data.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';

class LiveDataBootstrap {
  static final RealtimeDataController _controller = RealtimeDataController();

  static bool _initialized = false;
  static StreamSubscription<List<Map<String, dynamic>>>? _usersSubscription;
  static StreamSubscription<Map<String, dynamic>?>? _officeSubscription;
  static StreamSubscription<List<Map<String, dynamic>>>?
  _attendanceSubscription;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final users = await _controller.fetchUserRecords();
      setUsersFinalData(users);
    } catch (_) {}

    try {
      final office = await _controller.fetchOfficeConnection();
      if (office != null) {
        setOfficeMasterData(office);
      }
    } catch (_) {}

    try {
      final records = await _controller.fetchAttendanceRecords();
      setAttendanceRecords(records);
    } catch (_) {}

    _usersSubscription = _controller.watchUserRecords().listen(
      setUsersFinalData,
      onError: (_) {},
    );

    _officeSubscription = _controller.watchOfficeConnection().listen((office) {
      if (office == null) return;
      setOfficeMasterData(office);
    }, onError: (_) {});

    _attendanceSubscription = _controller.watchAttendanceRecords().listen(
      setAttendanceRecords,
      onError: (_) {},
    );
  }

  static Future<void> dispose() async {
    await _usersSubscription?.cancel();
    await _officeSubscription?.cancel();
    await _attendanceSubscription?.cancel();
    _usersSubscription = null;
    _officeSubscription = null;
    _attendanceSubscription = null;
    _initialized = false;
  }
}
