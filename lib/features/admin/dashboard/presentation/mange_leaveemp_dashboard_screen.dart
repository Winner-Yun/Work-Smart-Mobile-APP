import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/mange_leaveemp_dashboard_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';

class MangeLeaveEmpDashboardScreen extends StatefulWidget {
  const MangeLeaveEmpDashboardScreen({super.key});

  @override
  State<MangeLeaveEmpDashboardScreen> createState() =>
      _MangeLeaveEmpDashboardScreenState();
}

class _MangeLeaveEmpDashboardScreenState
    extends State<MangeLeaveEmpDashboardScreen> {
  late final LeaveRequestsController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = LeaveRequestsController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeManager(),
        LanguageManager(),
        _controller,
      ]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            final isCompact = !isDesktop;

            final mainContent = Column(
              children: [
                AdminHeaderBar(_scaffoldKey),
                Expanded(
                  child: Container(
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor, // Clean background
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isCompact ? 16 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequestStats(),
                          const SizedBox(height: 32),
                          _buildLeaveRequestsTable(
                            isCompact,
                          ).animate().fade().slideY(begin: 0.2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              drawer: isCompact
                  ? Drawer(
                      child: AdminSideBar(
                        isCompact: true,
                        leaverequestsSelected: true,
                        onDashboardTap: () =>
                            _navigateTo(AppAdminRoute.adminDashboard),
                        onStaffTap: () =>
                            _navigateTo(AppAdminRoute.staffManagement),
                        onGeofencingTap: () =>
                            _navigateTo(AppAdminRoute.geofencing),
                        onLeaderboardTap: () =>
                            _navigateTo(AppAdminRoute.performanceLeaderboard),
                        onLeaveRequestsTap: () =>
                            _navigateTo(AppAdminRoute.leaveRequests),
                        onReportsTap: () =>
                            _navigateTo(AppAdminRoute.analyticsReports),
                        onSettingsTap: () =>
                            _navigateTo(AppAdminRoute.systemSettings),
                      ),
                    )
                  : null,
              body: Row(
                children: [
                  if (isDesktop)
                    AdminSideBar(
                      isCompact: false,
                      leaverequestsSelected: true,
                      onDashboardTap: () =>
                          _navigateTo(AppAdminRoute.adminDashboard),
                      onStaffTap: () =>
                          _navigateTo(AppAdminRoute.staffManagement),
                      onGeofencingTap: () =>
                          _navigateTo(AppAdminRoute.geofencing),
                      onLeaderboardTap: () =>
                          _navigateTo(AppAdminRoute.performanceLeaderboard),
                      onLeaveRequestsTap: () =>
                          _navigateTo(AppAdminRoute.leaveRequests),
                      onReportsTap: () =>
                          _navigateTo(AppAdminRoute.analyticsReports),
                      onSettingsTap: () =>
                          _navigateTo(AppAdminRoute.systemSettings),
                    ),
                  Expanded(child: mainContent),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestStats() {
    final stats = _controller.getRequestStats();

    Widget statCard(String label, String value, IconData icon, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle, // Circular icons look more modern
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: statCard(
            AppStrings.tr('pending_requests'),
            stats['pending'].toString(),
            Icons.schedule_rounded,
            AppColors.secondary,
          ).animate().fade().slideY(begin: 0.2),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: statCard(
            AppStrings.tr('approved_requests'),
            stats['approved'].toString(),
            Icons.check_circle_rounded,
            AppColors.success,
          ).animate().fade().slideY(begin: 0.2),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: statCard(
            AppStrings.tr('rejected_requests'),
            stats['rejected'].toString(),
            Icons.cancel_rounded,
            AppColors.error,
          ).animate().fade().slideY(begin: 0.2),
        ),
      ],
    );
  }

  Widget _buildLeaveRequestsTable(bool isCompact) {
    final requests = _controller.filteredRequests;

    Widget header(String text) => Expanded(
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 0.8,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr('leave_requests'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.tr('manage_employee_leave'),
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // Text Search
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _controller.filterRequests(value);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('search_leave_requests'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _controller.filterRequests('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.02),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Range Filter
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.02),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _controller.startDate != null
                                      ? 'From: ${_controller.startDate.toString().split(' ')[0]}'
                                      : 'Start Date',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _controller.startDate != null
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.02),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _controller.endDate != null
                                      ? 'To: ${_controller.endDate.toString().split(' ')[0]}'
                                      : 'End Date',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _controller.endDate != null
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_controller.startDate != null ||
                        _controller.endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.1),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                          onPressed: () {
                            _controller.clearDateRange();
                            setState(() {});
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.015),
            child: Row(
              children: [
                header(AppStrings.tr('employee')),
                header(AppStrings.tr('leave_type')),
                header(AppStrings.tr('dates')),
                header(AppStrings.tr('reason')),
                header(AppStrings.tr('status')),
                const SizedBox(width: 100), // Fixed width for actions column
              ],
            ),
          ),

          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),

          // Table Rows
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.tr('no_requests_found'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.05),
              ),
              itemBuilder: (context, index) {
                final request = requests[index];
                final statusColor = request.status == 'approved'
                    ? AppColors.success
                    : request.status == 'rejected'
                    ? AppColors.error
                    : AppColors.secondary;

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      hoverColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.02),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        child: Row(
                          children: [
                            // Employee
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.employeeName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    request.employeeId,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Leave Type
                            Expanded(
                              child: Text(
                                request.leaveType,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ),
                            // Dates
                            Expanded(
                              child: Text(
                                '${request.startDate} - ${request.endDate}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                            // Reason
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  request.reason,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                            // Status
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        request.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actions
                            SizedBox(
                              width: 140,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (request.status == 'pending') ...[
                                    Tooltip(
                                      message: AppStrings.tr('approve'),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.check_rounded,
                                          size: 20,
                                        ),
                                        color: AppColors.success,
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.success
                                              .withOpacity(0.1),
                                          hoverColor: AppColors.success
                                              .withOpacity(0.2),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        onPressed: () =>
                                            _controller.updateRequestStatus(
                                              request.id,
                                              'approved',
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: AppStrings.tr('reject'),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                        ),
                                        color: AppColors.error,
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.error
                                              .withOpacity(0.1),
                                          hoverColor: AppColors.error
                                              .withOpacity(0.2),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        onPressed: () =>
                                            _controller.updateRequestStatus(
                                              request.id,
                                              'rejected',
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (request.status == 'approved' ||
                                      request.status == 'rejected')
                                    Tooltip(
                                      message: 'Edit',
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          size: 20,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        style: IconButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          hoverColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.2),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        onPressed: () {
                                          _showEditDialog(context, request);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 8), // Bottom padding
        ],
      ),
    );
  }

  void _navigateTo(String routeName) {
    if (mounted) {
      Navigator.of(context).pushNamed(routeName);
      if (_scaffoldKey.currentState?.isDrawerOpen == true) {
        Navigator.pop(context);
      }
    }
  }

  void _showEditDialog(BuildContext context, LeaveRequest request) {
    String selectedStatus = request.status;
    final statusColors = {
      'pending': AppColors.secondary,
      'approved': AppColors.success,
      'rejected': AppColors.error,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final newStatusColor =
                statusColors[selectedStatus] ?? AppColors.secondary;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'កែប្រែ${AppStrings.tr('leave_requests')}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              AppStrings.tr('change_status_leave_request'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body with information and dropdown
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee Information
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request.employeeName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            request.employeeId,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.1),
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.tr('leave_type'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            request.leaveType,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.tr('dates'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${request.startDate} - ${request.endDate}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Status Change Section
                          Text(
                            AppStrings.tr('change_status_leave_request'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Status Dropdown with enhanced styling
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: InputDecoration(
                              labelText: AppStrings.tr('new_status'),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.02),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: newStatusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  selectedStatus == 'approved'
                                      ? Icons.check_circle_rounded
                                      : selectedStatus == 'rejected'
                                      ? Icons.cancel_rounded
                                      : Icons.schedule_rounded,
                                  size: 18,
                                  color: newStatusColor,
                                ),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColors['pending'],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Pending'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'approved',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColors['approved'],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Approved'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'rejected',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColors['rejected'],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Rejected'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Current vs New Status Indicator
                          if (selectedStatus != request.status)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_rounded,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Status will change from ${request.status.replaceFirst(request.status[0], request.status[0].toUpperCase())} to ${selectedStatus.replaceFirst(selectedStatus[0], selectedStatus[0].toUpperCase())}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    AppStrings.tr('cancel'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStatus != request.status) {
                      _controller.updateRequestStatus(
                        request.id,
                        selectedStatus,
                      );
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppStrings.tr('save_changes'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              actionsPadding: const EdgeInsets.all(20),
            );
          },
        );
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final isDarkMode = ThemeManager().isDarkMode;
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.primary,
                    surface: Theme.of(context).colorScheme.surface,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  )
                : ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                    surface: Theme.of(context).colorScheme.surface,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _controller.setDateRange(picked, _controller.endDate);
      setState(() {});
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final isDarkMode = ThemeManager().isDarkMode;
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.primary,
                    surface: Theme.of(context).colorScheme.surface,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  )
                : ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                    surface: Theme.of(context).colorScheme.surface,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _controller.setDateRange(_controller.startDate, picked);
      setState(() {});
    }
  }
}
