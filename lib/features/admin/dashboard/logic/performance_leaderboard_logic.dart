import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

class PerformanceLeaderboardController extends ChangeNotifier {
  List<UserProfile> _allEmployees = [];
  List<UserProfile> _filteredEmployees = [];
  final Map<String, String> _searchIndexByUid = <String, String>{};
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
      _buildSearchIndex();
      _applyFiltersAndSort();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading employees: $e');
      }
    }
  }

  void _buildSearchIndex() {
    _searchIndexByUid
      ..clear()
      ..addEntries(
        _allEmployees.map((employee) {
          final searchableContent = [
            employee.displayName,
            employee.uid,
            employee.email,
            employee.departmentId,
            employee.roleTitle,
          ].join(' ');

          return MapEntry(
            employee.uid,
            _normalizeSearchText(searchableContent),
          );
        }),
      );
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _tokenizeSearchQuery(String value) {
    final normalized = _normalizeSearchText(value);
    if (normalized.isEmpty) {
      return const <String>[];
    }

    return normalized.split(' ').where((part) => part.isNotEmpty).toList();
  }

  void _applyFiltersAndSort() {
    _filteredEmployees = List.from(_allEmployees);

    // Filter by search query
    final searchTerms = _tokenizeSearchQuery(_searchQuery);
    if (searchTerms.isNotEmpty) {
      _filteredEmployees = _filteredEmployees.where((emp) {
        final searchableText =
            _searchIndexByUid[emp.uid] ??
            _normalizeSearchText(
              '${emp.displayName} ${emp.uid} ${emp.email} ${emp.departmentId} ${emp.roleTitle}',
            );

        return searchTerms.every((term) => searchableText.contains(term));
      }).toList();
    }

    // Filter by department
    if (_selectedDepartment != 'all') {
      final selectedDepartmentNormalized = _selectedDepartment.toLowerCase();
      _filteredEmployees = _filteredEmployees.where((emp) {
        return emp.departmentId.toLowerCase() == selectedDepartmentNormalized;
      }).toList();
    }

    // Sort employees
    _filteredEmployees.sort((a, b) {
      int compareValue;

      switch (_sortBy) {
        case 'score':
          compareValue = b.achievements.performanceScore.compareTo(
            a.achievements.performanceScore,
          );
          break;
        case 'attendance':
          final attendanceA = _calculateAttendanceRate(a);
          final attendanceB = _calculateAttendanceRate(b);
          compareValue = attendanceB.compareTo(attendanceA);
          break;
        case 'medals':
          compareValue = b.achievements.totalMedals.compareTo(
            a.achievements.totalMedals,
          );
          break;
        default:
          compareValue = b.achievements.performanceScore.compareTo(
            a.achievements.performanceScore,
          );
          break;
      }

      if (compareValue != 0) {
        return compareValue;
      }

      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    notifyListeners();
  }

  double _calculateAttendanceRate(UserProfile user) {
    // Mock calculation - in real app, calculate from attendance data
    return user.achievements.performanceScore / 100;
  }

  void searchEmployees(String query) {
    final normalizedCurrentQuery = _normalizeSearchText(_searchQuery);
    final normalizedIncomingQuery = _normalizeSearchText(query);

    if (normalizedCurrentQuery == normalizedIncomingQuery) {
      _searchQuery = query;
      return;
    }

    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

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
    departments.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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
