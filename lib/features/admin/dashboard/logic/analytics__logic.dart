import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

class AnalyticsController extends ChangeNotifier {
  late final List<UserProfile> _allEmployees;
  String _selectedMetric = 'attendance';
  String _selectedPeriod = 'month';
  String _selectedDepartment = 'all';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;

  AnalyticsController() {
    _allEmployees = usersFinalData
        .map((json) => UserProfile.fromJson(json))
        .toList();
  }

  String get selectedMetric => _selectedMetric;
  String get selectedPeriod => _selectedPeriod;
  String get selectedDepartment => _selectedDepartment;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;

  Future<void> changeMetric(String metric) async {
    _setLoading(true);
    _selectedMetric = metric;
    await Future.delayed(const Duration(milliseconds: 600));
    _setLoading(false);
  }

  Future<void> changePeriod(String period) async {
    _setLoading(true);
    _selectedPeriod = period;
    await Future.delayed(const Duration(milliseconds: 600));
    _setLoading(false);
  }

  Future<void> changeMonth(int month) async {
    _setLoading(true);
    _selectedMonth = month;
    await Future.delayed(const Duration(milliseconds: 450));
    _setLoading(false);
  }

  Future<void> changeYear(int year) async {
    _setLoading(true);
    _selectedYear = year;
    await Future.delayed(const Duration(milliseconds: 450));
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void changeDepartment(String dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  List<String> getAllDepartments() {
    final departments = <String>{'all'}; // Add 'all' option explicitly
    for (var user in _allEmployees) {
      departments.add(user.departmentId);
    }
    return departments.toList();
  }

  // Helper to get employees filtered by department
  List<UserProfile> get _filteredEmployees {
    if (_selectedDepartment == 'all') return _allEmployees;
    return _allEmployees
        .where((e) => e.departmentId == _selectedDepartment)
        .toList();
  }

  // --- Metrics Getters ---

  Map<String, dynamic> getAttendanceMetrics() {
    final employees = _filteredEmployees;
    double totalPresent = 0;
    double totalAbsent = 0;
    double totalLate = 0;

    for (var emp in employees) {
      final score = emp.achievements.performanceScore;
      totalPresent += (score / 100) * 20;
      totalAbsent += ((100 - score) / 100) * 3;
      totalLate += ((100 - score) / 100) * 2;
    }

    final total = totalPresent + totalAbsent + totalLate;

    return {
      'presentDays': totalPresent.toInt(),
      'absentDays': totalAbsent.toInt(),
      'lateDays': totalLate.toInt(),
      'presentRate': total > 0 ? (totalPresent / total) * 100 : 0,
      'totalEmployees': employees.length,
      // Mock Trends
      'presentTrend': 2.5,
      'absentTrend': -1.2,
      'lateTrend': 0.5,
    };
  }

  Map<String, dynamic> getPerformanceMetrics() {
    final employees = _filteredEmployees;
    if (employees.isEmpty) {
      return {
        'avgScore': 0.0,
        'highPerformers': 0,
        'mediumPerformers': 0,
        'lowPerformers': 0,
        'improving': 0,
        'totalEmployees': 0,
        // Mock Trends
        'avgScoreTrend': 0.0,
        'highTrend': 0.0,
        'lowTrend': 0.0,
      };
    }

    final scores = employees
        .map((e) => e.achievements.performanceScore.toDouble())
        .toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;

    return {
      'avgScore': avgScore,
      'highPerformers': employees
          .where((e) => e.achievements.performanceScore >= 80)
          .length,
      'mediumPerformers': employees
          .where(
            (e) =>
                e.achievements.performanceScore >= 60 &&
                e.achievements.performanceScore < 80,
          )
          .length,
      'lowPerformers': employees
          .where((e) => e.achievements.performanceScore < 60)
          .length,
      'improving': employees.where((e) => e.achievements.rankTrend > 0).length,
      'totalEmployees': employees.length,
      // Mock Trends
      'avgScoreTrend': 5.4,
      'highTrend': 12.0,
      'lowTrend': -5.0,
    };
  }

  Map<String, dynamic> getLeaveMetrics() {
    final employees = _filteredEmployees;
    if (employees.isEmpty) {
      return {
        'totalRequests': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'approvalRate': 0,
        'totalEmployees': 0,
        // Mock Trends
        'requestTrend': 0.0,
        'pendingTrend': 0.0,
      };
    }
    int totalRequests = 0;
    int approved = 0;
    int pending = 0;
    int rejected = 0;

    for (var emp in employees) {
      final requests =
          (emp.achievements.performanceScore / 100 * 5).toInt() + 1;
      totalRequests += requests;
      approved += (requests * 0.7).toInt();
      pending += (requests * 0.15).toInt();
      rejected += (requests * 0.15).toInt();
    }

    return {
      'totalRequests': totalRequests,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'approvalRate': totalRequests > 0 ? (approved / totalRequests) * 100 : 0,
      'totalEmployees': employees.length,
      // Mock Trends
      'requestTrend': 8.0,
      'pendingTrend': -2.0,
    };
  }

  Map<String, dynamic> getProductivityMetrics() {
    final employees = _filteredEmployees;
    if (employees.isEmpty) {
      return {
        'avgMedals': 0.0,
        'topTeam': 0,
        'activeTeam': 0,
        'inactiveTeam': 0,
        'totalEmployees': 0,
        // Mock Trends
        'medalTrend': 0.0,
        'activeTrend': 0.0,
      };
    }

    final medals = employees
        .map((e) => e.achievements.totalMedals.toDouble())
        .toList();
    final avgMedals = medals.reduce((a, b) => a + b) / medals.length;

    return {
      'avgMedals': avgMedals,
      'topTeam': employees
          .where((e) => e.achievements.totalMedals >= (avgMedals * 1.5).toInt())
          .length,
      'activeTeam': employees
          .where(
            (e) =>
                e.achievements.totalMedals >= (avgMedals * 0.5).toInt() &&
                e.achievements.totalMedals < (avgMedals * 1.5).toInt(),
          )
          .length,
      'inactiveTeam': employees
          .where((e) => e.achievements.totalMedals < (avgMedals * 0.5).toInt())
          .length,
      'totalEmployees': employees.length,
      // Mock Trends
      'medalTrend': 15.3,
      'activeTrend': 4.1,
    };
  }

  // --- Chart Data Builder ---

  List<ChartDataPoint> getChartData() {
    final metrics = getMetricData();
    // Helper to safe cast
    int val(String key) => (metrics[key] as num? ?? 0).toInt();

    switch (_selectedMetric) {
      case 'attendance':
        return [
          ChartDataPoint('Present', val('presentDays'), Colors.greenAccent),
          ChartDataPoint('Absent', val('absentDays'), Colors.redAccent),
          ChartDataPoint('Late', val('lateDays'), Colors.orangeAccent),
        ];
      case 'performance':
        return [
          ChartDataPoint(
            'High Perf.',
            val('highPerformers'),
            Colors.purpleAccent,
          ),
          ChartDataPoint(
            'Medium Perf.',
            val('mediumPerformers'),
            Colors.blueAccent,
          ),
          ChartDataPoint('Low Perf.', val('lowPerformers'), Colors.pinkAccent),
        ];
      case 'leaves':
        return [
          ChartDataPoint('Approved', val('approved'), Colors.tealAccent),
          ChartDataPoint('Pending', val('pending'), Colors.amberAccent),
          ChartDataPoint('Rejected', val('rejected'), Colors.redAccent),
        ];
      case 'productivity':
        return [
          ChartDataPoint('Top Team', val('topTeam'), Colors.indigoAccent),
          ChartDataPoint('Active', val('activeTeam'), Colors.cyanAccent),
          ChartDataPoint('Inactive', val('inactiveTeam'), Colors.grey),
        ];
      default:
        return [];
    }
  }

  Map<String, dynamic> getMetricData() {
    switch (_selectedMetric) {
      case 'performance':
        return getPerformanceMetrics();
      case 'leaves':
        return getLeaveMetrics();
      case 'productivity':
        return getProductivityMetrics();
      default:
        return getAttendanceMetrics();
    }
  }

  String getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'quarter':
        return 'This Quarter';
      case 'year':
        return 'This Year';
      default:
        return 'All Time';
    }
  }
}

class ChartDataPoint {
  final String label;
  final int value;
  final Color color;
  ChartDataPoint(this.label, this.value, this.color);
}
