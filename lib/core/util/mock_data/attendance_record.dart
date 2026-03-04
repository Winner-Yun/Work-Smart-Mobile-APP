import 'dart:math';

import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';

final Random _random = Random();

final List<Map<String, dynamic>> attendanceRecords =
    _buildAttendanceRecordsFromOctToNowForAllEmployees();

const String _demoAccountUid = 'user_winner_777';

List<Map<String, dynamic>>
_buildAttendanceRecordsFromOctToNowForAllEmployees() {
  final employeeIds = usersFinalData
      .map((user) => user['uid'])
      .whereType<String>()
      .where((uid) => uid != _demoAccountUid)
      .toList();

  final records = <Map<String, dynamic>>[];
  for (final uid in employeeIds) {
    records.addAll(_buildAttendanceRecordsFromOctToNow(uid));
  }

  records.addAll(_buildNonDailyAttendanceForDemoAccount());

  return records;
}

List<Map<String, dynamic>> _buildNonDailyAttendanceForDemoAccount() {
  final demoUserExists = usersFinalData.any(
    (user) => user['uid'] == _demoAccountUid,
  );
  if (!demoUserExists) return [];

  final now = DateTime.now();
  final startYear = now.month >= 10 ? now.year : now.year - 1;
  final startDate = DateTime(startYear, 10, 1);
  final records = <Map<String, dynamic>>[];

  for (
    var day = startDate;
    !day.isAfter(now);
    day = day.add(const Duration(days: 2))
  ) {
    final isAbsent = _random.nextInt(6) == 0;
    final isLate = _random.nextInt(4) == 0;
    final lateMinutes = isLate ? (5 + _random.nextInt(11)) : 0;

    records.add(
      _buildAttendanceRecord(
        uid: _demoAccountUid,
        date: day,
        isAbsent: isAbsent,
        isLate: !isAbsent && isLate,
        lateMinutes: lateMinutes,
      ),
    );
  }

  return records;
}

List<Map<String, dynamic>> _buildAttendanceRecordsFromOctToNow(String uid) {
  final userExists = usersFinalData.any((user) => user['uid'] == uid);
  if (!userExists) return [];

  final now = DateTime.now();
  final startYear = now.month >= 10 ? now.year : now.year - 1;
  final startDate = DateTime(startYear, 10, 1);

  final records = <Map<String, dynamic>>[];

  for (
    var day = startDate;
    !day.isAfter(now);
    day = day.add(const Duration(days: 1))
  ) {
    final isAbsent = _random.nextInt(12) == 0;
    final isLate = !isAbsent && _random.nextInt(5) == 0;
    final lateMinutes = isLate ? (5 + _random.nextInt(21)) : 0;

    records.add(
      _buildAttendanceRecord(
        uid: uid,
        date: day,
        isAbsent: isAbsent,
        isLate: isLate,
        lateMinutes: lateMinutes,
      ),
    );
  }

  return records;
}

Map<String, dynamic> _buildAttendanceRecord({
  required String uid,
  required DateTime date,
  required bool isAbsent,
  required bool isLate,
  required int lateMinutes,
}) {
  return {
    'uid': uid,
    'date': _formatDate(date),
    'check_in': isAbsent
        ? null
        : (isLate
              ? '08:${lateMinutes.toString().padLeft(2, '0')} AM'
              : '08:00 AM'),
    'check_out': isAbsent ? null : '05:00 PM',
    'total_hours': isAbsent ? 0.0 : (isLate ? (9 - (lateMinutes / 60)) : 9.0),
    'status': isAbsent ? 'absent' : (isLate ? 'late' : 'on_time'),
    'lat_lng': {'lat': 11.572, 'lng': 104.893},
  };
}

String _formatDate(DateTime date) {
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
