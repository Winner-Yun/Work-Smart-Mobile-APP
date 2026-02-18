import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

class PerformanceLeaderboardController extends ChangeNotifier {
  List<UserProfile> _allEmployees = [];
  List<UserProfile> _filteredEmployees = [];
  String _searchQuery = '';
  String _selectedDepartment = 'all';
  String _selectedPeriod = 'month'; // month, quarter, year
  String _sortBy = 'score'; // score, attendance, tasks
  bool _isLoading = false;

  List<UserProfile> get filteredEmployees => _filteredEmployees;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  String get selectedPeriod => _selectedPeriod;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;

  PerformanceLeaderboardController() {
    _loadEmployees();
  }

  void _loadEmployees() {
    try {
      _allEmployees = usersFinalData
          .map((json) => UserProfile.fromJson(json))
          .toList();
      _applyFiltersAndSort();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading employees: $e');
      }
    }
  }

  void _applyFiltersAndSort() {
    _filteredEmployees = List.from(_allEmployees);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      _filteredEmployees = _filteredEmployees.where((emp) {
        return emp.displayName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            emp.uid.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by department
    if (_selectedDepartment != 'all') {
      _filteredEmployees = _filteredEmployees.where((emp) {
        return emp.departmentId == _selectedDepartment;
      }).toList();
    }

    // Sort employees
    _filteredEmployees.sort((a, b) {
      switch (_sortBy) {
        case 'score':
          return b.achievements.performanceScore.compareTo(
            a.achievements.performanceScore,
          );
        case 'attendance':
          final attendanceA = _calculateAttendanceRate(a);
          final attendanceB = _calculateAttendanceRate(b);
          return attendanceB.compareTo(attendanceA);
        case 'medals':
          return b.achievements.totalMedals.compareTo(
            a.achievements.totalMedals,
          );
        default:
          return b.achievements.performanceScore.compareTo(
            a.achievements.performanceScore,
          );
      }
    });

    notifyListeners();
  }

  double _calculateAttendanceRate(UserProfile user) {
    // Mock calculation - in real app, calculate from attendance data
    return user.achievements.performanceScore / 100;
  }

  void searchEmployees(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> filterByDepartment(String department) async {
    _setLoading(true);
    _selectedDepartment = department;
    _applyFiltersAndSort();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  Future<void> changePeriod(String period) async {
    _setLoading(true);
    _selectedPeriod = period;
    _applyFiltersAndSort();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  Future<void> changeSortBy(String sortBy) async {
    _setLoading(true);
    _sortBy = sortBy;
    _applyFiltersAndSort();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'all';
    _selectedPeriod = 'month';
    _sortBy = 'score';
    _applyFiltersAndSort();
  }

  List<String> getAllDepartments() {
    final departments = _allEmployees
        .map((e) => e.departmentId)
        .toSet()
        .toList();
    departments.sort();
    return departments;
  }

  Map<String, dynamic> getStatistics() {
    if (_filteredEmployees.isEmpty) {
      return {'total': 0, 'avgScore': 0.0, 'topPerformer': '-', 'improved': 0};
    }

    final totalScore = _filteredEmployees.fold<double>(
      0,
      (sum, emp) => sum + emp.achievements.performanceScore,
    );
    final avgScore = totalScore / _filteredEmployees.length;
    final topPerformer = _filteredEmployees.first.displayName;
    final improved = _filteredEmployees
        .where((e) => e.achievements.rankTrend > 0)
        .length;

    return {
      'total': _filteredEmployees.length,
      'avgScore': avgScore,
      'topPerformer': topPerformer,
      'improved': improved,
    };
  }

  int getRank(UserProfile employee) {
    final index = _filteredEmployees.indexWhere((e) => e.uid == employee.uid);
    return index + 1;
  }
}
