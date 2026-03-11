import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';

List<LeaveRequest> _getLeaveRequestsFromUserData() {
  final List<LeaveRequest> requests = [];

  for (var user in usersFinalData) {
    final leaveRecords = user['leave_records'] as List<dynamic>?;
    if (leaveRecords != null) {
      for (var record in leaveRecords) {
        final dynamic statusUpdatedAtRaw =
            record['status_updated_at_utc'] ??
            record['status_updated_at'] ??
            record['updated_at_utc'] ??
            record['updated_at'];
        final dynamic statusUpdatedAtUnixRaw =
            record['status_updated_at_unix'] ??
            record['status_updated_at_ts'] ??
            record['updated_at_unix'] ??
            record['updated_at_ts'];

        final String? statusUpdatedAtUtc = _toUtcIsoString(statusUpdatedAtRaw);
        final int? statusUpdatedAtUnix =
            _toUnixMillis(statusUpdatedAtUnixRaw) ??
            _toUnixMillis(statusUpdatedAtUtc);

        requests.add(
          LeaveRequest(
            id: (record['request_id'] ?? '').toString(),
            employeeId: (user['uid'] ?? '').toString(),
            employeeName: (user['display_name'] ?? '').toString(),
            profileUrl: (user['profile_url'] ?? '').toString(),
            leaveType: _mapLeaveType((record['type'] ?? '').toString()),
            startDate: _normalizeDateString(record['start_date']),
            endDate: _normalizeDateString(record['end_date']),
            reason: (record['reason'] ?? '').toString(),
            attachmentUrl: record['attachment_url'] as String?,
            status: (record['status'] ?? 'pending').toString().toLowerCase(),
            statusUpdatedAtUtc: statusUpdatedAtUtc,
            statusUpdatedAtUnix: statusUpdatedAtUnix,
          ),
        );
      }
    }
  }

  return requests;
}

// Map leave type from mock data format to display format
String _mapLeaveType(String type) {
  const typeMap = {
    'annual_leave': 'Annual Leave',
    'sick_leave': 'Sick Leave',
    'personal_leave': 'Personal Leave',
    'maternity_leave': 'Maternity Leave',
  };
  return typeMap[type] ?? type;
}

String _normalizeDateString(dynamic value) {
  final String? maybeIso = _toUtcIsoString(value);
  if (maybeIso == null || maybeIso.isEmpty) {
    return DateTime.now().toUtc().toIso8601String();
  }
  return maybeIso;
}

String? _toUtcIsoString(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate().toUtc().toIso8601String();
  }

  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(
      value,
      isUtc: true,
    ).toIso8601String();
  }

  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.toInt(),
      isUtc: true,
    ).toIso8601String();
  }

  final String text = value.toString().trim();
  if (text.isEmpty) return null;

  final DateTime? parsedDate = DateTime.tryParse(text);
  if (parsedDate != null) {
    return parsedDate.toUtc().toIso8601String();
  }

  return text;
}

int? _toUnixMillis(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate().toUtc().millisecondsSinceEpoch;
  }

  if (value is DateTime) {
    return value.toUtc().millisecondsSinceEpoch;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  final String text = value.toString().trim();
  if (text.isEmpty) return null;

  final int? asInt = int.tryParse(text);
  if (asInt != null) {
    return asInt;
  }

  final DateTime? parsedDate = DateTime.tryParse(text);
  if (parsedDate != null) {
    return parsedDate.toUtc().millisecondsSinceEpoch;
  }

  return null;
}

List<Map<String, dynamic>> _copyLeaveRecords(dynamic value) {
  if (value is! List) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

class LeaveRequestsController extends ChangeNotifier {
  final RealtimeDataController _realtimeDataController;

  List<LeaveRequest> _allRequests = <LeaveRequest>[];
  List<LeaveRequest> _filteredRequests = <LeaveRequest>[];
  String _searchQuery = '';
  String _leaveTypeFilter = 'all';
  String _statusFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  LeaveRequestsController({RealtimeDataController? realtimeDataController})
    : _realtimeDataController =
          realtimeDataController ?? RealtimeDataController() {
    _reloadRequestsFromSource(notify: false);
  }

  List<LeaveRequest> get filteredRequests => _filteredRequests;
  String get searchQuery => _searchQuery;
  String get leaveTypeFilter => _leaveTypeFilter;
  String get statusFilter => _statusFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _reloadRequestsFromSource({bool notify = true}) {
    _allRequests = _getLeaveRequestsFromUserData();
    _applyFilters();
    if (notify) {
      notifyListeners();
    }
  }

  void filterRequests(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setLeaveTypeFilter(String value) {
    _leaveTypeFilter = value;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    _applyFilters();
    notifyListeners();
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _setLoading(true);
    _startDate = start;
    _endDate = end;
    _applyFilters();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  Future<void> clearDateRange() async {
    _setLoading(true);
    _startDate = null;
    _endDate = null;
    _applyFilters();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  void _applyFilters() {
    _filteredRequests = _allRequests.where((request) {
      // Text search
      bool textMatch =
          _searchQuery.isEmpty ||
          request.employeeName.toLowerCase().contains(_searchQuery) ||
          request.employeeId.toLowerCase().contains(_searchQuery);

      if (!textMatch) return false;

      final normalizedLeaveType = request.leaveType.toLowerCase();
      final leaveTypeMatches =
          _leaveTypeFilter == 'all' ||
          (_leaveTypeFilter == 'sick' &&
              normalizedLeaveType.contains('sick')) ||
          (_leaveTypeFilter == 'annual' &&
              normalizedLeaveType.contains('annual'));

      if (!leaveTypeMatches) return false;

      final statusMatches =
          _statusFilter == 'all' ||
          request.status.toLowerCase() == _statusFilter;

      if (!statusMatches) return false;

      // Date range filter
      if (_startDate != null || _endDate != null) {
        final DateTime? requestStart = DateTime.tryParse(request.startDate);
        final DateTime? requestEnd = DateTime.tryParse(request.endDate);

        if (requestStart == null || requestEnd == null) {
          return false;
        }

        if (_startDate != null && requestEnd.isBefore(_startDate!)) {
          return false;
        }

        if (_endDate != null && requestStart.isAfter(_endDate!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Map<String, int> getRequestStats() {
    return {
      'pending': _allRequests.where((r) => r.status == 'pending').length,
      'approved': _allRequests.where((r) => r.status == 'approved').length,
      'rejected': _allRequests.where((r) => r.status == 'rejected').length,
    };
  }

  Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    final String normalizedStatus = newStatus.trim().toLowerCase();
    if (normalizedStatus != 'pending' &&
        normalizedStatus != 'approved' &&
        normalizedStatus != 'rejected') {
      return false;
    }

    bool didUpdate = false;
    _setLoading(true);

    try {
      final int userIndex = usersFinalData.indexWhere((user) {
        final List<Map<String, dynamic>> leaveRecords = _copyLeaveRecords(
          user['leave_records'],
        );
        return leaveRecords.any(
          (record) => record['request_id']?.toString() == requestId,
        );
      });

      if (userIndex < 0) {
        return false;
      }

      final String uid =
          usersFinalData[userIndex]['uid']?.toString().trim() ?? '';
      if (uid.isEmpty) {
        return false;
      }

      final List<Map<String, dynamic>> leaveRecords = _copyLeaveRecords(
        usersFinalData[userIndex]['leave_records'],
      );

      final int leaveIndex = leaveRecords.indexWhere(
        (record) => record['request_id']?.toString() == requestId,
      );
      if (leaveIndex < 0) {
        return false;
      }

      leaveRecords[leaveIndex]['status'] = normalizedStatus;

      await _realtimeDataController.updateUserRecord(uid, {
        'leave_records': leaveRecords,
      });

      usersFinalData[userIndex]['leave_records'] = leaveRecords;
      _reloadRequestsFromSource(notify: false);
      didUpdate = true;
    } catch (_) {
      didUpdate = false;
    } finally {
      _setLoading(false);
    }

    return didUpdate;
  }
}
