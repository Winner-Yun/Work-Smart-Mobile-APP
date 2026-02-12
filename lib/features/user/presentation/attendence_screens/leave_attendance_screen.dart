import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/attendence_screens/leave_detail_view_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/leave_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaveAttendanceScreen(),
    ),
  );
}

class LeaveAttendanceScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const LeaveAttendanceScreen({super.key, this.loginData});

  @override
  State<LeaveAttendanceScreen> createState() => _LeaveAttendanceScreenState();
}

class _LeaveAttendanceScreenState extends State<LeaveAttendanceScreen> {
  static const int _annualTotal = 18;
  static const int _sickTotal = 5;

  late UserProfile _currentUser;
  late List<LeaveRecord> _leaveRecords;
  late List<LeaveRecord> _history;
  late int _annualUsed;
  late int _sickUsed;
  late int _annualRemaining;
  late int _sickRemaining;
  late Map<String, dynamic>? loginData;

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    loginData = widget.loginData;
    _loadData();
  }

  void _loadData() {
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == (widget.loginData?['uid'] ?? "user_winner_777"),
      orElse: () => usersFinalData[0],
    );
    _currentUser = UserProfile.fromJson(currentUserData);
    _leaveRecords = _currentUser.leaveRecords;

    _annualUsed = _sumUsedDays('annual_leave');
    _sickUsed = _sumUsedDays('sick_leave');
    _annualRemaining = (_annualTotal - _annualUsed).clamp(0, _annualTotal);
    _sickRemaining = (_sickTotal - _sickUsed).clamp(0, _sickTotal);

    _history = _leaveRecords.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  int _sumUsedDays(String type) {
    final approvedRecords = _leaveRecords
        .where((record) => record.type == type && record.status == 'approved')
        .toList();

    return approvedRecords.fold(
      0,
      (sum, record) => sum + record.durationInDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildBottomAction(context).animate().slideY(
        begin: 1,
        end: 0,
        duration: 400.ms,
        curve: Curves.easeOutQuad,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED TOP SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(context)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 30),
                _buildListHeader(context),
              ],
            ),
          ),

          // SCROLLABLE LIST SECTION
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _history.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final record = _history[index];
                return _buildRequestListItem(
                      context: context,
                      title: _getLeaveTitle(record.type),
                      subtitle: _formatDateRange(record),
                      status: _getStatusText(record.status),
                      statusColor: _getStatusColor(record.status),
                      icon: _getLeaveIcon(record.type),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LeaveDetailViewScreen(leave: record),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. AppBar Widget ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      title: Text(
        AppStrings.tr('leave_menu'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoute.notificationScreen,
            arguments: loginData,
          ),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).iconTheme.color,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().shake(delay: 1.seconds, duration: 500.ms),
        ),
      ],
    );
  }

  // --- 2. Leave Summary Section ---
  Widget _buildSummarySection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context: context,
            title: AppStrings.tr('annual_leave'),
            value: _annualRemaining.toString().padLeft(2, '0'),
            icon: Icons.calendar_today_outlined,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSummaryCard(
            context: context,
            title: AppStrings.tr('sick_leave'),
            value: _sickRemaining.toString().padLeft(2, '0'),
            icon: Icons.medical_services_outlined,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  // --- 3. Request List Header ---
  Widget _buildListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.tr('recent_requests'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoute.leaveAllRequestsScreen,
              arguments: loginData,
            );
          },
          child: Text(
            AppStrings.tr('view_all'),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  // --- 4. Fixed Bottom Action ---
  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.sickleaveScreen,
                  arguments: loginData,
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 55),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                AppStrings.tr('request_sick_leave'),
                maxLines: 1, // Fix: Prevent text wrapping
                overflow: TextOverflow.ellipsis, // Fix: Handle overflow
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.annualleaveScreen,
                  arguments: loginData,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(0, 55),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                AppStrings.tr('request_annual_leave'),
                maxLines: 1, // Fix: Prevent text wrapping
                overflow: TextOverflow.ellipsis, // Fix: Handle overflow
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Private Helper Components ---

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1, // Fix: Prevent wrapping
            overflow: TextOverflow.ellipsis, // Fix: Handle overflow
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  AppStrings.tr('days_remaining'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLeaveTitle(String type) {
    switch (type) {
      case 'annual_leave':
        return AppStrings.tr('annual_leave');
      case 'sick_leave':
        return AppStrings.tr('sick_leave');
      default:
        return type.replaceAll('_', ' ');
    }
  }

  IconData _getLeaveIcon(String type) {
    switch (type) {
      case 'annual_leave':
        return Icons.beach_access_outlined;
      case 'sick_leave':
        return Icons.medical_services_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return AppStrings.tr('status_approved');
      case 'rejected':
        return AppStrings.tr('status_rejected');
      case 'pending':
      default:
        return AppStrings.tr('status_pending');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatDateRange(LeaveRecord record) {
    final DateTime startDate = record.startDate;
    final DateTime endDate = record.endDate;

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return _dateFormatter.format(startDate);
    }

    final String endText = DateFormat('dd MMM yyyy').format(endDate);
    String startText = DateFormat('dd MMM').format(startDate);

    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      startText = DateFormat('dd').format(startDate);
    }

    return '$startText - $endText';
  }

  Widget _buildRequestListItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).dividerColor.withOpacity(0.1),
                child: Icon(icon, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
