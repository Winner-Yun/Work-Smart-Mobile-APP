import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

class AttendentRecordController extends ChangeNotifier {
  final RealtimeDataController _realtimeDataController;

  StreamSubscription<List<Map<String, dynamic>>>? _usersSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _attendanceSubscription;

  List<UserProfile> _users = <UserProfile>[];
  List<AttendanceRecord> _attendanceRecords = <AttendanceRecord>[];

  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _departmentFilter = 'all';

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  DateTime? _lastSyncedAt;

  AttendentRecordController({RealtimeDataController? realtimeDataController})
    : _realtimeDataController =
          realtimeDataController ?? RealtimeDataController();

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get departmentFilter => _departmentFilter;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  List<String> get availableDepartmentIds {
    final ids = _users
        .map((user) => user.departmentId.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    ids.sort();
    return ids;
  }

  bool get isToday =>
      _formatDateKey(_selectedDate) == _formatDateKey(DateTime.now());

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await refresh();
    _subscribeToRealtimeData();
  }

  Future<void> refresh() async {
    _setLoading(true);

    try {
      final usersRaw = await _realtimeDataController.fetchUserRecords();
      final attendanceRaw = await _realtimeDataController
          .fetchAttendanceRecords();

      _users = usersRaw.map(UserProfile.fromJson).toList();
      _normalizeDepartmentFilter();
      _attendanceRecords = attendanceRaw
          .map(AttendanceRecord.fromJson)
          .toList();
      _errorMessage = null;
      _lastSyncedAt = DateTime.now();
    } catch (_) {
      _errorMessage = 'Unable to load attendance records right now.';
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (_formatDateKey(normalized) == _formatDateKey(_selectedDate)) {
      return;
    }

    _selectedDate = normalized;
    notifyListeners();
  }

  void shiftSelectedDateBy(int dayDelta) {
    setSelectedDate(_selectedDate.add(Duration(days: dayDelta)));
  }

  void setSearchQuery(String query) {
    final normalized = query.trim();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    notifyListeners();
  }

  void setDepartmentFilter(String filter) {
    if (_departmentFilter == filter) return;
    _departmentFilter = filter;
    notifyListeners();
  }

  AttendanceSummary get summary {
    final rows = _rowsForSelectedDate;

    int present = 0;
    int late = 0;
    int absent = 0;
    double totalHours = 0;
    int hoursCount = 0;

    for (final row in rows) {
      if (row.status == 'present') {
        present++;
      } else if (row.status == 'late') {
        late++;
      } else {
        absent++;
      }

      if (row.totalHours > 0) {
        totalHours += row.totalHours;
        hoursCount++;
      }
    }

    final avgHours = hoursCount == 0 ? 0.0 : totalHours / hoursCount;

    return AttendanceSummary(
      totalEmployees: rows.length,
      presentCount: present,
      lateCount: late,
      absentCount: absent,
      averageHours: avgHours,
    );
  }

  List<AttendentRecordRow> get filteredRows {
    var rows = _rowsForSelectedDate;

    if (_statusFilter != 'all') {
      rows = rows.where((row) => row.status == _statusFilter).toList();
    }

    if (_departmentFilter != 'all') {
      rows = rows
          .where((row) => row.departmentId == _departmentFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      rows = rows.where((row) {
        return row.name.toLowerCase().contains(search) ||
            row.uid.toLowerCase().contains(search) ||
            row.email.toLowerCase().contains(search) ||
            row.checkIn.toLowerCase().contains(search) ||
            row.checkOut.toLowerCase().contains(search);
      }).toList();
    }

    return rows;
  }

  bool get hasAnyRows => _rowsForSelectedDate.isNotEmpty;

  List<AttendentRecordRow> get _rowsForSelectedDate {
    final dateKey = _formatDateKey(_selectedDate);

    final recordsForDate = _attendanceRecords
        .where((record) => record.date == dateKey)
        .toList(growable: false);

    final recordsByUid = <String, AttendanceRecord>{
      for (final record in recordsForDate) record.uid: record,
    };

    final rows = <AttendentRecordRow>[];

    for (final user in _users) {
      final attendance = recordsByUid.remove(user.uid);

      rows.add(
        AttendentRecordRow(
          uid: user.uid,
          name: user.displayName.trim().isEmpty ? user.uid : user.displayName,
          departmentId: user.departmentId,
          email: user.email,
          profileUrl: user.profileUrl,
          checkIn: attendance?.checkIn ?? '--:--',
          checkOut: attendance?.checkOut ?? '--:--',
          totalHours: attendance?.totalHours ?? 0.0,
          status: attendance == null ? 'absent' : _normalizeStatus(attendance),
          lat: attendance?.location.lat,
          lng: attendance?.location.lng,
        ),
      );
    }

    for (final record in recordsByUid.values) {
      rows.add(
        AttendentRecordRow(
          uid: record.uid,
          name: record.uid,
          departmentId: '',
          email: '',
          profileUrl: '',
          checkIn: record.checkIn,
          checkOut: record.checkOut,
          totalHours: record.totalHours,
          status: _normalizeStatus(record),
          lat: record.location.lat,
          lng: record.location.lng,
        ),
      );
    }

    rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return rows;
  }

  String _normalizeStatus(AttendanceRecord attendance) {
    final status = attendance.status.trim().toLowerCase();
    if (status == 'late') return 'late';
    if (status == 'present' || status == 'on_time' || status == 'on-time') {
      return 'present';
    }

    if (!_hasScanValue(attendance.checkIn)) {
      return 'absent';
    }

    return 'present';
  }

  bool _hasScanValue(String value) {
    final normalized = value.trim();
    return normalized.isNotEmpty && normalized != '--:--';
  }

  String _formatDateKey(DateTime dateTime) {
    return '${dateTime.year}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _normalizeDepartmentFilter() {
    if (_departmentFilter == 'all') return;
    if (!availableDepartmentIds.contains(_departmentFilter)) {
      _departmentFilter = 'all';
    }
  }

  void _subscribeToRealtimeData() {
    _usersSubscription?.cancel();
    _attendanceSubscription?.cancel();

    _usersSubscription = _realtimeDataController.watchUserRecords().listen(
      (usersRaw) {
        _users = usersRaw.map(UserProfile.fromJson).toList();
        _normalizeDepartmentFilter();
        _errorMessage = null;
        _lastSyncedAt = DateTime.now();
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Realtime user updates are temporarily unavailable.';
        notifyListeners();
      },
    );

    _attendanceSubscription = _realtimeDataController
        .watchAttendanceRecords()
        .listen(
          (attendanceRaw) {
            _attendanceRecords = attendanceRaw
                .map(AttendanceRecord.fromJson)
                .toList();
            _errorMessage = null;
            _lastSyncedAt = DateTime.now();
            notifyListeners();
          },
          onError: (_) {
            _errorMessage =
                'Realtime attendance updates are temporarily unavailable.';
            notifyListeners();
          },
        );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _attendanceSubscription?.cancel();
    super.dispose();
  }
}

class AttendentRecordRow {
  final String uid;
  final String name;
  final String departmentId;
  final String email;
  final String profileUrl;
  final String checkIn;
  final String checkOut;
  final double totalHours;
  final String status;
  final double? lat;
  final double? lng;

  const AttendentRecordRow({
    required this.uid,
    required this.name,
    required this.departmentId,
    required this.email,
    required this.profileUrl,
    required this.checkIn,
    required this.checkOut,
    required this.totalHours,
    required this.status,
    this.lat,
    this.lng,
  });
}

class AttendanceSummary {
  final int totalEmployees;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final double averageHours;

  const AttendanceSummary({
    required this.totalEmployees,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.averageHours,
  });
}
