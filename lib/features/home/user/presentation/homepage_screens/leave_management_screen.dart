import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/leave_detail_view_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/leave_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:intl/intl.dart';

class LeaveDetailScreen extends StatefulWidget {
  const LeaveDetailScreen({super.key});

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _annualController;
  late AnimationController _sickController;
  late Animation<double> _annualAnimation;
  late Animation<double> _sickAnimation;

  static const int _annualTotal = 18;
  static const int _sickTotal = 5;

  late UserProfile _currentUser;
  late List<LeaveRecord> _leaveRecords;
  late List<LeaveRecord> _history;
  late int _annualUsed;
  late int _sickUsed;
  late double _annualRatio;
  late double _sickRatio;

  @override
  void initState() {
    super.initState();
    _loadData();
    _annualController = AnimationController(vsync: this, duration: 1500.ms);
    _sickController = AnimationController(vsync: this, duration: 1500.ms);

    _annualAnimation = Tween<double>(begin: 0, end: _annualRatio).animate(
      CurvedAnimation(parent: _annualController, curve: Curves.easeInOut),
    );
    _sickAnimation = Tween<double>(begin: 0, end: _sickRatio).animate(
      CurvedAnimation(parent: _sickController, curve: Curves.easeInOut),
    );

    _annualController.forward();
    _sickController.forward();
  }

  void _loadData() {
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == "user_winner_777",
      orElse: () => usersFinalData[0],
    );
    _currentUser = UserProfile.fromJson(currentUserData);

    // Only load CURRENT USER's leave records, not all users
    _leaveRecords = _currentUser.leaveRecords;

    debugPrint('=== Leave Data for User: ${_currentUser.uid} ===');
    debugPrint('Total leave records: ${_leaveRecords.length}');
    for (var record in _leaveRecords) {
      debugPrint(
        'Record: ${record.type} | ${record.startDate} to ${record.endDate} | Status: ${record.status} | Days: ${record.durationInDays}',
      );
    }

    _annualUsed = _sumUsedDays('annual_leave');
    _sickUsed = _sumUsedDays('sick_leave');

    debugPrint(
      'FINAL COUNTS - Annual: $_annualUsed/$_annualTotal | Sick: $_sickUsed/$_sickTotal',
    );

    _annualRatio = (_annualUsed / _annualTotal).clamp(0, 1).toDouble();
    _sickRatio = (_sickUsed / _sickTotal).clamp(0, 1).toDouble();

    _history = _leaveRecords.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  int _sumUsedDays(String type) {
    final approvedRecords = _leaveRecords
        .where((record) => record.type == type && record.status == 'approved')
        .toList();

    debugPrint(
      'Counting approved "$type" records: found ${approvedRecords.length}',
    );

    return approvedRecords.fold(
      0,
      (sum, record) => sum + record.durationInDays,
    );
  }

  @override
  void dispose() {
    _annualController.dispose();
    _sickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDoubleOverviewCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  AppStrings.tr('request_history'),
                  AppStrings.tr('view_all'),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final record = _history[index];
                return _buildTimelineItem(record);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('leave_details_title'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDoubleOverviewCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLeaveProgressItem(
                  _annualAnimation,
                  _annualUsed,
                  _annualTotal,
                  AppStrings.tr('annual_leave'),
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                child: _buildLeaveProgressItem(
                  _sickAnimation,
                  _sickUsed,
                  _sickTotal,
                  AppStrings.tr('sick_leave'),
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 5),
              Text(
                '${AppStrings.tr('you_have_remaining_leave')} ${(_annualTotal - _annualUsed) + (_sickTotal - _sickUsed)} ${AppStrings.tr('days')} ${AppStrings.tr('this_year')}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveProgressItem(
    Animation<double> animation,
    int used,
    int total,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        _buildAnimatedCircularIndicator(animation, used, total, color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${AppStrings.tr('remaining')} ${total - used} ${AppStrings.tr('days')}",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCircularIndicator(
    Animation<double> animation,
    int used,
    int total,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 55,
              height: 55,
              child: CircularProgressIndicator(
                value: animation.value,
                strokeWidth: 5,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color == Colors.white ? AppColors.secondary : color,
                ),
              ),
            ),
            Text(
              "$used/$total",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem(LeaveRecord record) {
    final String titleKey = record.type;
    final String statusKey = _getStatusKey(record.status);
    final Color color = _getStatusColor(record.status);
    final String dateLabel = _formatDateRange(record.startDate, record.endDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeaveDetailViewScreen(leave: record),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr(titleKey),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                AppStrings.tr(statusKey),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('dd MMM yyyy');
    final startLabel = formatter.format(start);
    final endLabel = formatter.format(end);

    if (startLabel == endLabel) {
      return startLabel;
    }
    return "$startLabel - $endLabel";
  }

  String _getStatusKey(String status) {
    switch (status) {
      case 'approved':
        return 'status_approved';
      case 'rejected':
        return 'status_rejected';
      case 'pending':
      default:
        return 'status_pending';
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

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        if (action.isNotEmpty)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.pushNamed(context, AppRoute.leaveAllRequestsScreen);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                action,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                Navigator.pushNamed(context, AppRoute.sickleaveScreen);
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.annualleaveScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(0, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                AppStrings.tr('request_annual_leave'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
