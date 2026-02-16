import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/attendance_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const AttendanceCalendarScreen({super.key, this.loginData});

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  late UserProfile _currentUser;
  late List<AttendanceRecord> _userAttendanceRecords;
  late String? loggedInUserId;

  late int _selectedDay;
  late DateTime _currentViewDate;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now.day;
    _currentViewDate = DateTime(now.year, now.month);
    loggedInUserId = widget.loginData?['uid'];
    _loadData();
  }

  void _loadData() {
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == (loggedInUserId ?? "user_winner_777"),
      orElse: () => usersFinalData[0],
    );
    _currentUser = UserProfile.fromJson(currentUserData);

    _userAttendanceRecords = attendanceRecords
        .where((record) => record['uid'] == _currentUser.uid)
        .map((json) => AttendanceRecord.fromJson(json))
        .toList();
  }

  String _getLocalizedMonthYear(DateTime date) {
    String monthKey = 'month_${DateFormat('MMM').format(date).toLowerCase()}';
    return "${AppStrings.tr(monthKey)} ${date.year}";
  }

  Map<String, dynamic> _getDayData(int day) {
    final searchDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(_currentViewDate.year, _currentViewDate.month, day));

    final match = _userAttendanceRecords
        .where((record) => record.date == searchDate)
        .toList();

    if (match.isEmpty) {
      return {
        "in": "--:--",
        "out": "--:--",
        "h": "0",
        "s": "no_data",
        "c": Colors.grey,
      };
    }

    final record = match.first;
    final color = record.status == 'on_time'
        ? Colors.green
        : record.status == 'late'
        ? Colors.orange
        : Colors.red;

    return {
      "in": record.checkIn,
      "out": record.checkOut,
      "h": record.totalHours.toStringAsFixed(1),
      "s": record.status,
      "c": color,
    };
  }

  int _getMonthAttendanceRate(DateTime date) {
    final monthRecords = _userAttendanceRecords.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.year == date.year && recordDate.month == date.month;
    }).toList();

    if (monthRecords.isEmpty) return 0;

    final onTimeCount = monthRecords
        .where((record) => record.status == 'on_time')
        .length;
    final rate = (onTimeCount / monthRecords.length) * 100;

    return rate.round();
  }

  @override
  Widget build(BuildContext context) {
    var dayData = _getDayData(_selectedDay);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendarHeader(),
                  _buildLegend().animate().fadeIn(delay: 200.ms),
                  _buildCalendarGrid(),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDayDetailView(dayData),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('attendance_calendar_title'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.file_download_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.tr('download_report')),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getLocalizedMonthYear(_currentViewDate),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                "${_getMonthAttendanceRate(_currentViewDate)}% ${AppStrings.tr('avg_attendance')}",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildNavCircle(Icons.chevron_left, () => _updateMonth(-1)),
              const SizedBox(width: 15),
              _buildNavCircle(Icons.chevron_right, () => _updateMonth(1)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  void _updateMonth(int add) {
    setState(() {
      _currentViewDate = DateTime(
        _currentViewDate.year,
        _currentViewDate.month + add,
      );
    });
  }

  Widget _buildNavCircle(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildLegendDot(Colors.green, AppStrings.tr('present')),
          const SizedBox(width: 15),
          _buildLegendDot(Colors.orange, AppStrings.tr('late')),
          const SizedBox(width: 15),
          _buildLegendDot(Colors.red, AppStrings.tr('absent')),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    final daysInMonth = DateUtils.getDaysInMonth(
      _currentViewDate.year,
      _currentViewDate.month,
    );
    final firstDayOffset =
        DateTime(_currentViewDate.year, _currentViewDate.month, 1).weekday - 1;

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map(
                (d) => Text(
                  d,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: 35,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            int dayNum = index - firstDayOffset + 1;
            bool isGrey = dayNum <= 0 || dayNum > daysInMonth;
            return GestureDetector(
              onTap: isGrey
                  ? null
                  : () => setState(() => _selectedDay = dayNum),
              child: _buildDayCell(dayNum, isGrey),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDayCell(int day, bool isGrey) {
    bool isSelected = _selectedDay == day && !isGrey;
    var dayData = isGrey ? null : _getDayData(day);
    Color? dotColor = (dayData != null && dayData['s'] != "no_data")
        ? dayData['c']
        : null;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              isGrey ? "" : "$day",
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isGrey
                          ? Colors.grey[300]
                          : Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ),
        ),
        if (!isGrey && dotColor != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ).animate().scale(),
      ],
    );
  }

  Widget _buildDayDetailView(Map<String, dynamic> data) {
    return Column(
      key: ValueKey("$_selectedDay-${_currentViewDate.month}"),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${AppStrings.tr('day_label')} $_selectedDay ${_getLocalizedMonthYear(_currentViewDate)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              _buildStatusTag(AppStrings.tr(data['s']), data['c']),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildInfoCard(
              AppStrings.tr('check_in_title'),
              data['in'],
              Icons.login,
              Colors.green,
            ),
            const SizedBox(width: 10),
            _buildInfoCard(
              AppStrings.tr('check_out_title'),
              data['out'],
              Icons.logout,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildTotalCard(data['h']),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String time, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(String hours) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                AppStrings.tr('total_work_hours'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            "$hours ${AppStrings.tr('hours_unit')}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
