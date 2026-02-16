import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/officeMasterData.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

// ==========================================
// 1. STATE MANAGEMENT
// ==========================================
class DashboardController extends ChangeNotifier {
  bool _isSidebarCollapsed = false;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }
}

// ==========================================
// 3. LOGIC & DATA MAPPING
// ==========================================
final OfficeConfig _officeConfig = OfficeConfig.fromJson(officeMasterData);
final List<AttendanceRecord> _attendanceRecords = attendanceRecords
    .map(AttendanceRecord.fromJson)
    .toList();
final Map<String, UserProfile> _usersById = {
  for (final user in usersFinalProfiles) user.uid: user,
};


OfficeConfig getOfficeConfig() => _officeConfig;

String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'NA';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.substring(0, 1).toUpperCase();
  final last = parts.last.substring(0, 1).toUpperCase();
  return '$first$last';
}


DashboardStatsData buildDashboardStats({bool useToday = true}) {
  final totalEmployees = usersFinalProfiles.length;


  final todayKey = _formatDateKey(DateTime.now());
  final records = useToday
      ? _attendanceRecords.where((r) => r.date == todayKey).toList()
      : _attendanceRecords;

  final presentCount = records.map((e) => e.uid).toSet().length;
  final presentRate = totalEmployees == 0
      ? 0.0
      : presentCount / totalEmployees.toDouble();

  final onTimeCount = records.where((r) => r.status == 'on_time').length;
  final lateCount = records.where((r) => r.status == 'late').length;
  final onTimeRate = (onTimeCount + lateCount) == 0
      ? 0.0
      : onTimeCount / (onTimeCount + lateCount).toDouble();

  final pendingRequests = usersFinalProfiles
      .expand((u) => u.leaveRecords)
      .where((r) => r.status == 'pending')
      .length;

  return DashboardStatsData(
    totalEmployees: totalEmployees,
    presentCount: presentCount,
    presentRate: presentRate,
    onTimeCount: onTimeCount,
    lateCount: lateCount,
    onTimeRate: onTimeRate,
    pendingRequests: pendingRequests,
  );
}

/// Prepares data for the attendance table rows.
List<AttendanceRowData> buildAttendanceRows({
  int limit = 3,
  bool useToday = true,
}) {
  final todayKey = _formatDateKey(DateTime.now());
  final records = useToday
      ? _attendanceRecords.where((r) => r.date == todayKey).toList()
      : _attendanceRecords;

  final checkInStart = _officeConfig.policy.checkInStart.isNotEmpty
      ? _officeConfig.policy.checkInStart
      : '08:00 AM';
  final bufferMinutes = _officeConfig.policy.lateBufferMinutes;

  final rows = <AttendanceRowData>[];
  for (final record in records) {
    if (rows.length >= limit) break;

    final user = _usersById[record.uid];
    final isLate = record.status == 'late';

    String timeStatus = 'ON TIME';
    if (isLate) {
      final lateMinutes = _calculateLateMinutes(
        checkInStart,
        record.checkIn,
        bufferMinutes,
      );
      timeStatus = (lateMinutes != null && lateMinutes > 0)
          ? 'LATE (${lateMinutes}M)'
          : 'LATE';
    }

    rows.add(
      AttendanceRowData(
        name: user?.displayName ?? 'Unknown',
        dept: user?.roleTitle ?? 'Staff',
        checkIn: record.checkIn,
        checkOut: record.checkOut,
        statusLabel: isLate ? 'Late' : 'Verified',
        timeStatus: timeStatus,
        profileUrl: user?.profileUrl ?? '',
        isLate: isLate,
      ),
    );
  }
  return rows;
}

/// Prepares data for the top performers list.
List<TopPerformerData> buildTopPerformers({int limit = 3}) {
  final sorted = [...usersFinalProfiles]
    ..sort(
      (a, b) => b.achievements.performanceScore.compareTo(
        a.achievements.performanceScore,
      ),
    );

  return sorted.take(limit).map((user) {
    return TopPerformerData(
      name: user.displayName,
      dept: user.roleTitle,
      score: user.achievements.performanceScore.toString(),
      profileUrl: user.profileUrl,
    );
  }).toList();
}

// --- Internal Helpers ---

String _formatDateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

int? _calculateLateMinutes(String start, String checkIn, int buffer) {
  final s = _minutesFromTime(start);
  final c = _minutesFromTime(checkIn);
  if (s == null || c == null) return null;
  final diff = c - (s + buffer);
  return diff > 0 ? diff : 0;
}

int? _minutesFromTime(String time) {
  final parts = time.trim().split(' ');
  if (parts.length < 2) return null;
  final hm = parts[0].split(':');
  if (hm.length != 2) return null;

  int h = int.tryParse(hm[0]) ?? 0;
  final m = int.tryParse(hm[1]) ?? 0;

  if (parts[1].toUpperCase() == 'PM' && h != 12) h += 12;
  if (parts[1].toUpperCase() == 'AM' && h == 12) h = 0;

  return (h * 60) + m;
}
