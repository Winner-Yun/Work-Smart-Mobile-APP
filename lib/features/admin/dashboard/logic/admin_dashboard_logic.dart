import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/attendance_data.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/office_data.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

// ==========================================
// 1. STATE MANAGEMENT
// ==========================================
class DashboardController extends ChangeNotifier {
  bool _isSidebarCollapsed = false;
  bool _isLoading = false;

  bool get isSidebarCollapsed => _isSidebarCollapsed;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> toggleSidebar() async {
    _setLoading(true);
    _isSidebarCollapsed = !_isSidebarCollapsed;
    await Future.delayed(const Duration(milliseconds: 300));
    _setLoading(false);
  }
}

// ==========================================
// 3. LOGIC & DATA MAPPING
// ==========================================
final RealtimeDataController _realtimeDataController = RealtimeDataController();
final ValueNotifier<int> dashboardDataVersion = ValueNotifier<int>(0);

StreamSubscription<List<Map<String, dynamic>>>? _dashboardUsersSubscription;
StreamSubscription<List<Map<String, dynamic>>>? _dashboardOfficesSubscription;
StreamSubscription<List<Map<String, dynamic>>>?
_dashboardAttendanceSubscription;

OfficeConfig _officeConfig = OfficeConfig.fromJson(officeMasterData);
List<OfficeConfig> _officeConfigs = _officeConfig.officeId.isEmpty
    ? <OfficeConfig>[]
    : <OfficeConfig>[_officeConfig];
List<AttendanceRecord> _attendanceRecords = attendanceRecords
    .map(AttendanceRecord.fromJson)
    .toList();
List<UserProfile> _usersProfiles = List<UserProfile>.from(usersFinalProfiles);
Map<String, UserProfile> _usersById = {
  for (final user in _usersProfiles) user.uid: user,
};

Future<void> initializeDashboardRealtimeData() async {
  if (_dashboardUsersSubscription != null ||
      _dashboardOfficesSubscription != null ||
      _dashboardAttendanceSubscription != null) {
    return;
  }

  try {
    final users = await _realtimeDataController.fetchUserRecords();
    _updateDashboardUsers(users);

    final attendance = await _realtimeDataController.fetchAttendanceRecords();
    _updateDashboardAttendance(attendance);

    final offices = await _realtimeDataController.fetchOfficeConnections();
    if (offices.isNotEmpty) {
      _updateDashboardOffices(offices);
    } else {
      final office = await _realtimeDataController.fetchOfficeConnection();
      if (office != null) {
        _updateDashboardOffice(office);
      }
    }

    _dashboardUsersSubscription = _realtimeDataController
        .watchUserRecords()
        .listen(_updateDashboardUsers);

    _dashboardAttendanceSubscription = _realtimeDataController
        .watchAttendanceRecords()
        .listen(_updateDashboardAttendance);

    _dashboardOfficesSubscription = _realtimeDataController
        .watchOfficeConnections()
        .listen((offices) {
          if (offices.isEmpty) return;
          _updateDashboardOffices(offices);
        });
  } catch (_) {
    return;
  }
}

void disposeDashboardRealtimeData() {
  _dashboardUsersSubscription?.cancel();
  _dashboardOfficesSubscription?.cancel();
  _dashboardAttendanceSubscription?.cancel();
  _dashboardUsersSubscription = null;
  _dashboardOfficesSubscription = null;
  _dashboardAttendanceSubscription = null;
}

void _updateDashboardUsers(List<Map<String, dynamic>> users) {
  if (users.isEmpty) {
    _usersProfiles = List<UserProfile>.from(usersFinalProfiles);
  } else {
    _usersProfiles = users.map(UserProfile.fromJson).toList();
  }

  _usersById = {for (final user in _usersProfiles) user.uid: user};
  _notifyDashboardDataChanged();
}

void _updateDashboardOffice(Map<String, dynamic> office) {
  final updatedOffice = OfficeConfig.fromJson(office);
  _officeConfig = updatedOffice;

  final index = _officeConfigs.indexWhere(
    (officeConfig) => officeConfig.officeId == updatedOffice.officeId,
  );
  if (index == -1) {
    _officeConfigs = <OfficeConfig>[..._officeConfigs, updatedOffice];
  } else {
    _officeConfigs[index] = updatedOffice;
  }

  _notifyDashboardDataChanged();
}

void _updateDashboardOffices(List<Map<String, dynamic>> offices) {
  if (offices.isEmpty) return;

  final parsedOffices = offices.map(OfficeConfig.fromJson).toList()
    ..sort(
      (a, b) =>
          a.officeName.toLowerCase().compareTo(b.officeName.toLowerCase()),
    );

  _officeConfigs = parsedOffices;

  if (_officeConfig.officeId.isNotEmpty) {
    final matchedOffice = parsedOffices.where(
      (officeConfig) => officeConfig.officeId == _officeConfig.officeId,
    );
    _officeConfig = matchedOffice.isNotEmpty
        ? matchedOffice.first
        : parsedOffices.first;
  } else {
    _officeConfig = parsedOffices.first;
  }

  _notifyDashboardDataChanged();
}

void _updateDashboardAttendance(List<Map<String, dynamic>> records) {
  _attendanceRecords = records.map(AttendanceRecord.fromJson).toList();
  _notifyDashboardDataChanged();
}

void _notifyDashboardDataChanged() {
  dashboardDataVersion.value = dashboardDataVersion.value + 1;
}

OfficeConfig getOfficeConfig() => _officeConfig;

List<OfficeConfig> getAllOfficeConfigs() {
  if (_officeConfigs.isNotEmpty) {
    return List<OfficeConfig>.unmodifiable(_officeConfigs);
  }

  if (_officeConfig.officeId.isEmpty && _officeConfig.officeName.isEmpty) {
    return const <OfficeConfig>[];
  }

  return List<OfficeConfig>.unmodifiable(<OfficeConfig>[_officeConfig]);
}

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
  final totalEmployees = _usersProfiles.length;

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

  final pendingRequests = _usersProfiles
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

  final rows = <AttendanceRowData>[];
  for (final record in records) {
    if (rows.length >= limit) break;

    final user = _usersById[record.uid];
    final isLate = record.status == 'late';

    final String timeStatus = isLate ? 'LATE' : 'ON TIME';

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
        email: user?.email,
        phone: user?.phone,
        officeId: user?.officeId,
        departmentId: user?.departmentId,
      ),
    );
  }
  return rows;
}

/// Prepares data for the top performers list.
List<TopPerformerData> buildTopPerformers({int limit = 3}) {
  final sorted = [..._usersProfiles]
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
