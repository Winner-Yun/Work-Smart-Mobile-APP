import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  int _selectedDay = 10;
  DateTime _currentViewDate = DateTime(2023, 10);
  final bool _isLoading = false;

  // --- API MOCK DATA (Keys remain in English) ---
  final List<Map<String, dynamic>> _apiAttendanceList = [
    {
      "date": "2023-10-01",
      "in": "08:00 AM",
      "out": "05:00 PM",
      "h": "8",
      "s": "on_time",
      "c": Colors.green,
    },
    {
      "date": "2023-10-03",
      "in": "08:45 AM",
      "out": "05:30 PM",
      "h": "7.5",
      "s": "late",
      "c": Colors.orange,
    },
    {
      "date": "2023-10-05",
      "in": "--:--",
      "out": "--:--",
      "h": "0",
      "s": "absent",
      "c": Colors.red,
    },
    {
      "date": "2023-10-10",
      "in": "08:00 AM",
      "out": "05:00 PM",
      "h": "8",
      "s": "on_time",
      "c": Colors.green,
    },
    {
      "date": "2023-10-12",
      "in": "09:10 AM",
      "out": "05:00 PM",
      "h": "7",
      "s": "late",
      "c": Colors.orange,
    },
  ];

  // Helper to translate Month + Year based on AppStrings
  String _getLocalizedMonthYear(DateTime date) {
    String monthKey = 'month_${DateFormat('MMM').format(date).toLowerCase()}';
    return "${AppStrings.tr(monthKey)} ${date.year}";
  }

  Map<String, dynamic> _getDayData(int day) {
    String searchDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(_currentViewDate.year, _currentViewDate.month, day));

    return _apiAttendanceList.firstWhere(
      (element) => element['date'] == searchDate,
      orElse: () => {
        "in": "--:--",
        "out": "--:--",
        "h": "0",
        "s": "no_data",
        "c": Colors.grey,
      },
    );
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
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('attendance_calendar_title'),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.file_download_outlined,
            color: AppColors.primary,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.tr('download_report')),
                backgroundColor: AppColors.primary,
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
                "96% ${AppStrings.tr('avg_attendance')}",
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
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              isGrey ? "" : "$day",
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
              AppStrings.tr('check_in'),
              data['in'],
              Icons.login,
              Colors.green,
            ),
            const SizedBox(width: 10),
            _buildInfoCard(
              AppStrings.tr('check_out'),
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
