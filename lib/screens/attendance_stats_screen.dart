import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class AttendanceStatsScreen extends StatefulWidget {
  const AttendanceStatsScreen({super.key});

  @override
  State<AttendanceStatsScreen> createState() => _AttendanceStatsScreenState();
}

class _AttendanceStatsScreenState extends State<AttendanceStatsScreen> {
  bool _animateChart = false;
  String _selectedFilter = 'All';
  late int _selectedMonthIndex;
  late int _selectedYear;
  late List<Map<String, dynamic>> _monthlyStats;

  final List<String> _monthKeys = [
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
    _initializeData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _animateChart = true;
      });
    });
  }

  void _initializeData() {
    final now = DateTime.now();
    _selectedYear = now.year;
    _monthlyStats = [];

    for (int i = 4; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);

      _monthlyStats.add({
        "monthKey": _monthKeys[date.month],
        "year": date.year,
        "percentage": _getMockPercentage(i),
        "present": "${20 + i}",
        "late": "${5 - i}",
        "absent": "$i",
      });
    }

    _selectedMonthIndex = 4;
  }

  double _getMockPercentage(int index) {
    List<double> percs = [0.65, 0.80, 0.50, 0.90, 0.95];
    return percs[index % percs.length];
  }

  final List<Map<String, dynamic>> _historyData = [
    {
      "date": "25 Sep 2023",
      "day": "ថ្ងៃច័ន្ទ",
      "status": "វត្តមាន",
      "color": Colors.green,
      "checkIn": "08:00 AM",
      "checkOut": "05:00 PM",
      "hours": "8h",
      "isLate": false,
    },
    {
      "date": "24 Sep 2023",
      "day": "ថ្ងៃអាទិត្យ",
      "status": "ឈប់",
      "color": Colors.orange,
      "checkIn": "--:--",
      "checkOut": "--:--",
      "hours": "0h",
      "isLate": false,
    },
    {
      "date": "22 Sep 2023",
      "day": "ថ្ងៃសុក្រ",
      "status": "វត្តមាន",
      "color": Colors.green,
      "checkIn": "08:15 AM",
      "checkOut": "05:00 PM",
      "hours": "7h 45m",
      "isLate": true,
    },
    {
      "date": "21 Sep 2023",
      "day": "អវត្តមាន",
      "status": "អវត្តមាន",
      "color": Colors.red,
      "checkIn": "--:--",
      "checkOut": "--:--",
      "hours": "0h",
      "isLate": false,
    },
    {
      "date": "20 Sep 2023",
      "day": "ថ្ងៃពុធ",
      "status": "វត្តមាន",
      "color": Colors.green,
      "checkIn": "08:00 AM",
      "checkOut": "05:00 PM",
      "hours": "8h",
      "isLate": false,
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedFilter == 'All') return _historyData;
    if (_selectedFilter == 'Late') {
      return _historyData.where((e) => e['isLate'] == true).toList();
    }
    if (_selectedFilter == 'Absent') {
      return _historyData.where((e) => e['status'] == "អវត្តមាន").toList();
    }
    return _historyData;
  }

  @override
  Widget build(BuildContext context) {
    final currentStats = _monthlyStats[_selectedMonthIndex];
    final displayYear = currentStats['year'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.calendar_month, color: AppColors.primary),
          ),
        ],
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.tr('my_stats'),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_selectedMonthIndex),
                  tween: Tween<double>(
                    begin: 0,
                    end: currentStats['percentage'],
                  ),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[100],
                            color: AppColors.primary,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${(value * 100).toInt()}%",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              AppStrings.tr('attendance_rate'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppStrings.tr(currentStats['monthKey']),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB78103),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard(
                  Icons.check_circle_outline,
                  AppStrings.tr('present'),
                  currentStats['present'],
                  Colors.green,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.access_time,
                  AppStrings.tr('late'),
                  currentStats['late'],
                  Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.cancel_outlined,
                  AppStrings.tr('absent'),
                  currentStats['absent'],
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.tr('monthly_trend'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "$displayYear",
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 180,
                      width: MediaQuery.of(context).size.width - 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_monthlyStats.length, (index) {
                          final stat = _monthlyStats[index];
                          return _buildClickableBar(
                            index: index,
                            label: AppStrings.tr(stat['monthKey']),
                            percentage: stat['percentage'],
                            isActive: index == _selectedMonthIndex,
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(AppStrings.tr('all_shifts'), 'All'),
                  const SizedBox(width: 10),
                  _buildFilterChip(AppStrings.tr('late'), 'Late'),
                  const SizedBox(width: 10),
                  _buildFilterChip(AppStrings.tr('absent'), 'Absent'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.tr('monthly_attendance'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${AppStrings.tr(currentStats['monthKey'])} $displayYear",
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoute.attendanceDetail,
                      arguments: item,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['date'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['day'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['status'] == "ឈប់"
                                    ? Icons.access_time
                                    : item['status'] == "អវត្តមាន"
                                    ? Icons.cancel
                                    : Icons.check_circle,
                                size: 14,
                                color: item['color'],
                              ),
                              const SizedBox(width: 5),
                              Text(
                                item['status'],
                                style: TextStyle(
                                  color: item['color'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableBar({
    required int index,
    required String label,
    required double percentage,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonthIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isActive ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${(percentage * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 30,
            height: _animateChart ? 120 * percentage : 0,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : const Color(0xFFB0BEC5).withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: isActive
                  ? Border.all(color: AppColors.secondary, width: 2)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String count,
    Color color,
  ) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: double.infinity,
          key: ValueKey(count),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterKey) {
    final bool isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
