import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/leave_attendance.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/attendance_stats_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

abstract class AttendanceStatsLogic extends State<AttendanceStatsScreen> {
  late UserProfile currentUser;
  late List<AttendanceRecord> userAttendanceRecords;
  late List<Map<String, dynamic>> monthlyStats;

  bool animateChart = false;
  String selectedFilter = 'All';
  late int selectedMonthIndex;
  late int selectedYear;

  final List<String> monthKeys = [
    '',
    'month_jan',
    'month_feb',
    'month_mar',
    'month_apr',
    'month_may',
    'month_jun',
    'month_jul',
    'month_aug',
    'month_sep',
    'month_oct',
    'month_nov',
    'month_dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => animateChart = true);
    });
  }

  void _loadData() {
    // Load current user
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == "user_winner_777",
      orElse: () => usersFinalData[0],
    );
    currentUser = UserProfile.fromJson(currentUserData);

    // Load user's attendance records
    userAttendanceRecords = attendanceRecords
        .where((record) => record['uid'] == currentUser.uid)
        .map((json) => AttendanceRecord.fromJson(json))
        .toList();

    // Initialize monthly stats
    final now = DateTime.now();
    selectedYear = now.year;
    monthlyStats = [];

    for (int i = 4; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final percentage = _calculateMonthlyPercentage(date);
      final present = _countByStatus(date, 'on_time');
      final late = _countByStatus(date, 'late');

      monthlyStats.add({
        "monthKey": monthKeys[date.month],
        "year": date.year,
        "percentage": percentage,
        "present": present,
        "late": late,
        "absent": 0,
      });
    }
    selectedMonthIndex = 4;
  }

  /// Calculate monthly attendance percentage based on records
  /// Returns: (present + late) / total records for that month
  double _calculateMonthlyPercentage(DateTime month) {
    final monthRecords = userAttendanceRecords.where((r) {
      final recordDate = DateTime.parse(r.date);
      return recordDate.year == month.year && recordDate.month == month.month;
    }).toList();

    if (monthRecords.isEmpty) return 0.0;

    // Count: present (on_time) + late = attended
    final attendedCount = monthRecords
        .where((r) => r.status == 'on_time' || r.status == 'late')
        .length;

    // Percentage = attended / total records
    return attendedCount / monthRecords.length;
  }

  /// Count attendance by status for a specific month
  int _countByStatus(DateTime month, String status) {
    return userAttendanceRecords.where((r) {
      final recordDate = DateTime.parse(r.date);
      return recordDate.year == month.year &&
          recordDate.month == month.month &&
          r.status == status;
    }).length;
  }

  /// Get attendance records for history display
  List<Map<String, dynamic>> getAttendanceHistoryData() {
    return userAttendanceRecords.map((record) {
      final date = DateTime.parse(record.date);
      final dayName = _getDayName(date.weekday);

      return {
        "date": "${date.day} ${_getMonthName(date.month)} ${date.year}",
        "month": date.month,
        "year": date.year,
        "day": dayName,
        "status": record.status,
        "color": record.status == 'on_time'
            ? Colors.green
            : record.status == 'late'
            ? Colors.orange
            : Colors.red,
        "checkIn": record.checkIn,
        "checkOut": record.checkOut,
        "hours": _formatHours(record.totalHours),
        "isLate": record.status == 'late',
      };
    }).toList();
  }

  /// Get filtered attendance records
  List<Map<String, dynamic>> getFilteredAttendanceData() {
    final allData = getAttendanceHistoryData();
    final activeMonth = monthlyStats[selectedMonthIndex];
    final activeYear = activeMonth['year'] as int;
    final activeMonthKey = activeMonth['monthKey'] as String;
    final activeMonthIndex = monthKeys.indexOf(activeMonthKey);

    final monthData = allData.where((e) {
      return e['year'] == activeYear && e['month'] == activeMonthIndex;
    }).toList();

    if (selectedFilter == 'All') return monthData;
    if (selectedFilter == 'Late') {
      return monthData.where((e) => e['isLate'] == true).toList();
    }
    if (selectedFilter == 'Absent') {
      return monthData.where((e) => e['status'] == 'absent').toList();
    }
    return monthData;
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatHours(double hours) {
    final hourPart = hours.toInt();
    final minutePart = ((hours - hourPart) * 60).toInt();

    if (minutePart == 0) {
      return '${hourPart}h';
    }
    return '${hourPart}h ${minutePart}m';
  }
}
