import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/user/logic/leave_request_logic.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/attendence_screens/leave_detail_view_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/leave_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:intl/intl.dart';

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
  String? _selectedForRemoveRequestId;
  bool _isRemoveMode = false;

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

  void _handleLongPress(LeaveRecord record) {
    if (!LeaveRequestLogic.canRemoveStatus(record.status)) return;
    setState(() {
      final bool isSelectedForRemove =
          _selectedForRemoveRequestId == record.requestId;

      if (isSelectedForRemove) {
        _selectedForRemoveRequestId = null;
        _isRemoveMode = false;
      } else {
        _selectedForRemoveRequestId = record.requestId;
        _isRemoveMode = true;
      }
    });
  }

  Future<void> _handleTap(LeaveRecord record) async {
    final bool isSelectedForRemove =
        _selectedForRemoveRequestId == record.requestId;

    if (_isRemoveMode) {
      if (!LeaveRequestLogic.canRemoveStatus(record.status)) {
        await LeaveRequestLogic.showRemoveNotAllowedDialog(context);
        return;
      }
      setState(() {
        if (isSelectedForRemove) {
          _selectedForRemoveRequestId = null;
          _isRemoveMode = false;
        } else {
          _selectedForRemoveRequestId = record.requestId;
        }
      });
      return;
    }

    final bool? wasDeleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LeaveDetailViewScreen(leave: record, userId: _currentUser.uid),
      ),
    );

    if (wasDeleted == true && mounted) {
      setState(() {
        _selectedForRemoveRequestId = null;
        _isRemoveMode = false;
        _loadData();
      });
    }
  }

  Future<void> _confirmAndDelete(LeaveRecord record) async {
    final bool removed = await LeaveRequestLogic.confirmAndDeleteLeave(
      context,
      record: record,
      userId: _currentUser.uid,
    );
    if (!removed) return;

    setState(() {
      _selectedForRemoveRequestId = null;
      _isRemoveMode = false;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildBottomAction(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED TOP SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(context),
                const SizedBox(height: 30),
                _buildListHeader(context),
              ],
            ),
          ).animate().fadeIn(duration: 260.ms).slideY(begin: -0.04, end: 0),

          // SCROLLABLE LIST SECTION
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _history.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final record = _history[index];
                return _buildRequestListItem(
                      record: record,
                      context: context,
                      title: LeaveRequestLogic.getLeaveTitle(record.type),
                      subtitle: _formatDateRange(record),
                      status: LeaveRequestLogic.getStatusText(record.status),
                      statusColor: LeaveRequestLogic.getStatusColor(
                        record.status,
                      ),
                      icon: LeaveRequestLogic.getLeaveIcon(record.type),
                      onLongPress: () {
                        _handleLongPress(record);
                      },
                      onTap: () async {
                        await _handleTap(record);
                      },
                    )
                    .animate()
                    .fadeIn(delay: (index * 45).ms, duration: 220.ms)
                    .slideX(begin: 0.06, end: 0);
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
          ),
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
    );
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
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
        )
        .animate()
        .fadeIn(delay: 180.ms, duration: 240.ms)
        .slideY(begin: 0.1, end: 0);
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
    required LeaveRecord record,
    required BuildContext context,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    VoidCallback? onLongPress,
    VoidCallback? onTap,
  }) {
    final bool isRemovable = LeaveRequestLogic.canRemoveStatus(record.status);
    final bool isSelectedForRemove =
        isRemovable && _selectedForRemoveRequestId == record.requestId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
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
            border: isSelectedForRemove
                ? Border.all(
                    color: Colors.red.withValues(alpha: 0.35),
                    width: 1,
                  )
                : null,
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
              isSelectedForRemove
                  ? TextButton.icon(
                      onPressed: () => _confirmAndDelete(record),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(
                        AppStrings.tr('remove_button'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : Container(
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
