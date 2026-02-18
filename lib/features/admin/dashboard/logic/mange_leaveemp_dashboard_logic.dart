import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';

// Helper function to convert leave records from usersFinalData to LeaveRequest
List<LeaveRequest> _getLeaveRequestsFromMockData() {
  final List<LeaveRequest> requests = [];

  for (var user in usersFinalData) {
    final leaveRecords = user['leave_records'] as List<dynamic>?;
    if (leaveRecords != null) {
      for (var record in leaveRecords) {
        requests.add(
          LeaveRequest(
            id: record['request_id'] as String,
            employeeId: user['uid'] as String,
            employeeName: user['display_name'] as String,
            leaveType: _mapLeaveType(record['type'] as String),
            startDate: record['start_date'] as String,
            endDate: record['end_date'] as String,
            reason: record['reason'] as String,
            status: record['status'] as String,
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

class LeaveRequestsController extends ChangeNotifier {
  late final List<LeaveRequest> _allRequests;
  late List<LeaveRequest> _filteredRequests;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  LeaveRequestsController() {
    _allRequests = _getLeaveRequestsFromMockData();
    _filteredRequests = List.from(_allRequests);
  }

  List<LeaveRequest> get filteredRequests => _filteredRequests;
  String get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void filterRequests(String query) {
    _searchQuery = query.toLowerCase();
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
          request.employeeId.toLowerCase().contains(_searchQuery) ||
          request.leaveType.toLowerCase().contains(_searchQuery) ||
          request.reason.toLowerCase().contains(_searchQuery);

      if (!textMatch) return false;

      // Date range filter
      if (_startDate != null || _endDate != null) {
        final requestStart = DateTime.parse(request.startDate);
        final requestEnd = DateTime.parse(request.endDate);

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

  void updateRequestStatus(String requestId, String newStatus) {
    final index = _allRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final oldRequest = _allRequests[index];
      _allRequests[index] = LeaveRequest(
        id: oldRequest.id,
        employeeId: oldRequest.employeeId,
        employeeName: oldRequest.employeeName,
        leaveType: oldRequest.leaveType,
        startDate: oldRequest.startDate,
        endDate: oldRequest.endDate,
        reason: oldRequest.reason,
        status: newStatus,
      );
      // Reapply filter if search is active
      if (_searchQuery.isNotEmpty) {
        filterRequests(_searchQuery);
      } else {
        _filteredRequests = List.from(_allRequests);
      }
      notifyListeners();
    }
  }
}
