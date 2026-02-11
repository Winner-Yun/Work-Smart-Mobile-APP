import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/leave_detail_view_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/leave_record.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:intl/intl.dart';

class LeaveAllRequestsScreen extends StatefulWidget {
  const LeaveAllRequestsScreen({super.key});

  @override
  State<LeaveAllRequestsScreen> createState() => _LeaveAllRequestsScreenState();
}

class _LeaveAllRequestsScreenState extends State<LeaveAllRequestsScreen> {
  late UserProfile _currentUser;
  late List<LeaveRecord> _history;
  late List<LeaveRecord> _filteredHistory;
  DateTime? _selectedDate;

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == "user_winner_777",
      orElse: () => usersFinalData[0],
    );
    _currentUser = UserProfile.fromJson(currentUserData);

    _history = _currentUser.leaveRecords.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedDate == null) {
      _filteredHistory = _history.toList();
      return;
    }

    final DateTime target = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    _filteredHistory = _history.where((record) {
      final DateTime start = DateTime(
        record.startDate.year,
        record.startDate.month,
        record.startDate.day,
      );
      final DateTime end = DateTime(
        record.endDate.year,
        record.endDate.month,
        record.endDate.day,
      );
      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _applyFilter();
    });
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildDateFilter(context),
          Expanded(
            child: _filteredHistory.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final record = _filteredHistory[index];
                      return _buildRequestListItem(record)
                          .animate()
                          .fadeIn(delay: (80 * index).ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('request_history'),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'All dates'
                    : _dateFormatter.format(_selectedDate!),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _pickDate(context),
              child: Text(
                AppStrings.tr('select_date'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                onPressed: _clearDate,
                icon: const Icon(Icons.close, size: 18),
                color: Colors.grey,
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: AppColors.textGrey),
            const SizedBox(width: 10),
            Text(
              AppStrings.tr('no_records'),
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildRequestListItem(LeaveRecord record) {
    final String title = _getLeaveTitle(record.type);
    final String subtitle = _formatDateRange(record);
    final String status = _getStatusText(record.status);
    final Color statusColor = _getStatusColor(record.status);
    final IconData icon = _getLeaveIcon(record.type);

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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
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

    final String endText = _dateFormatter.format(endDate);
    String startText = DateFormat('dd MMM').format(startDate);

    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      startText = DateFormat('dd').format(startDate);
    }

    return '$startText - $endText';
  }
}
