import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/manage_users_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/manage_users_widgets.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late final ManageUsersController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = ManageUsersController();
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isCompact ? 16 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserStats(),
                          const SizedBox(height: 32),
                          _buildUsersTable(
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
                        staffSelected: true,
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
                      staffSelected: true,
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

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final first = parts.first.substring(0, 1);
    final last = parts.last.substring(0, 1);
    return (first + last).toUpperCase();
  }

  String _slugFromName(String name) {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join('_');
  }

  String _buildUserId(String name) {
    final slug = _slugFromName(name);
    return slug.isEmpty ? '' : 'user_${slug}_001';
  }

  String _buildEmail(String name) {
    final slug = _slugFromName(name);
    return slug.isEmpty ? '' : '$slug@worksmart.kh';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return AppStrings.tr('not_available');
    }
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return AppStrings.tr('status_active');
      case 'inactive':
        return AppStrings.tr('status_inactive');
      case 'suspended':
        return AppStrings.tr('status_suspended');
      default:
        return AppStrings.tr('status_unknown');
    }
  }

  String _faceStatusLabel(String? status) {
    switch (status) {
      case 'approved':
        return AppStrings.tr('face_status_approved');
      case 'rejected':
        return AppStrings.tr('face_status_rejected');
      default:
        return AppStrings.tr('face_status_pending');
    }
  }

  Widget _buildUserStats() {
    final stats = _controller.getUserStats();

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
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
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
            AppStrings.tr('total_users'),
            stats['total'].toString(),
            Icons.people_rounded,
            Theme.of(context).colorScheme.primary,
          ).animate().fade().slideY(begin: 0.2),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: statCard(
            AppStrings.tr('status_active'),
            stats['active'].toString(),
            Icons.check_circle_rounded,
            AppColors.success,
          ).animate().fade().slideY(begin: 0.2),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: statCard(
            AppStrings.tr('status_inactive'),
            stats['inactive'].toString(),
            Icons.pause_circle_rounded,
            AppColors.secondary,
          ).animate().fade().slideY(begin: 0.2),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: statCard(
            AppStrings.tr('status_suspended'),
            stats['suspended'].toString(),
            Icons.block_rounded,
            AppColors.error,
          ).animate().fade().slideY(begin: 0.2),
        ),
      ],
    );
  }

  Widget _buildUsersTable(bool isCompact) {
    final users = _controller.filteredUsers;
    final departments = _controller.getAllDepartments();

    Widget header(String text) => Expanded(
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr('manage_users_title'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.tr('manage_users_subtitle'),
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
                ElevatedButton.icon(
                  onPressed: () {
                    _showCreateUserDialog(context);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(AppStrings.tr('create_user')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('search_and_filter_title'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    if (_controller.selectedStatus != 'all' ||
                        _controller.selectedDepartment != 'all' ||
                        _searchController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(_controller.selectedStatus != 'all' ? 1 : 0) + (_controller.selectedDepartment != 'all' ? 1 : 0) + (_searchController.text.isNotEmpty ? 1 : 0)} ${AppStrings.tr('active_filters')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _controller.filterUsers(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: AppStrings.tr('search_users_hint'),
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.6),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _controller.filterUsers('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filters Row
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _controller.selectedStatus != 'all'
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3)
                                : Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.03),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _controller.selectedStatus,
                          decoration: InputDecoration(
                            labelText: AppStrings.tr('status_label'),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: Icon(
                              Icons.info_outline_rounded,
                              color: _controller.selectedStatus != 'all'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.4),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.fromLTRB(
                              12,
                              8,
                              8,
                              8,
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(
                                AppStrings.tr('all'),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.tr('status_active'),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.tr('status_inactive'),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'suspended',
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.tr('status_suspended'),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _controller.setStatus(value);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Department Filter
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _controller.selectedDepartment != 'all'
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3)
                                : Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.03),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _controller.selectedDepartment,
                          decoration: InputDecoration(
                            labelText: AppStrings.tr('department_label'),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: Icon(
                              Icons.business_center_outlined,
                              color: _controller.selectedDepartment != 'all'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.4),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.fromLTRB(
                              12,
                              8,
                              8,
                              8,
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(
                                AppStrings.tr('all_departments'),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            ...departments.map(
                              (dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(
                                  dept,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _controller.setDepartment(value);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Clear Filters Button
                    if (_controller.selectedStatus != 'all' ||
                        _controller.selectedDepartment != 'all' ||
                        _searchController.text.isNotEmpty)
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.2),
                            width: 1.5,
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.05),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _searchController.clear();
                              _controller.clearFilters();
                              setState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.tr('clear'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                header(AppStrings.tr('name_label')),
                header(AppStrings.tr('email_label')),
                header(AppStrings.tr('role_label')),
                header(AppStrings.tr('department_label')),
                header(AppStrings.tr('status_label')),
                const SizedBox(width: 100), // Fixed width for actions column
              ],
            ),
          ),

          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),

          // Table Rows
          if (users.isEmpty)
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
                        Icons.people_outline_rounded,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.tr('no_users_found'),
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
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.05),
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                final statusColor = user.status == 'active'
                    ? AppColors.success
                    : user.status == 'suspended'
                    ? AppColors.error
                    : AppColors.secondary;

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showUserDetailsDialog(context, user);
                      },
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
                            // User Avatar & Name
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    foregroundImage: NetworkImage(
                                      user.profileUrl,
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    child: Text(
                                      _initials(user.displayName),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.displayName,
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
                                          user.uid,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Email
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ),
                            // Role
                            Expanded(
                              child: Text(
                                user.roleTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                            // Department
                            Expanded(
                              child: Text(
                                user.departmentId,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
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
                                        _statusLabel(user.status),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actions
                            SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Tooltip(
                                    message: AppStrings.tr('edit'),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 20,
                                      ),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1),
                                        hoverColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.2),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      onPressed: () {
                                        _showEditDialog(context, user);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: AppStrings.tr('delete'),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        size: 20,
                                      ),
                                      color: AppColors.error,
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.error
                                            .withOpacity(0.1),
                                        hoverColor: AppColors.error.withOpacity(
                                          0.2,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      onPressed: () {
                                        _showDeleteConfirm(context, user);
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
          const SizedBox(height: 8),
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

  void _showEditDialog(BuildContext context, UserEmployee user) {
    String selectedStatus = user.status ?? 'active';
    final TextEditingController roleController = TextEditingController(
      text: user.roleTitle,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final statusColor = selectedStatus == 'active'
                ? AppColors.success
                : selectedStatus == 'suspended'
                ? AppColors.error
                : AppColors.secondary;

            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.manage_accounts_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.tr('user_settings_title'),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  AppStrings.tr('user_settings_subtitle'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionLabel(
                            context,
                            AppStrings.tr('identity_section'),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  foregroundImage: NetworkImage(
                                    user.profileUrl,
                                  ),
                                  child: Text(_initials(user.displayName)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildSectionLabel(
                            context,
                            AppStrings.tr('account_status_section'),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: _inputStyle(
                              context,
                              statusColor,
                              selectedStatus,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text(AppStrings.tr('status_active')),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text(AppStrings.tr('status_inactive')),
                              ),
                              DropdownMenuItem(
                                value: 'suspended',
                                child: Text(AppStrings.tr('status_suspended')),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => selectedStatus = val!),
                          ),
                          const SizedBox(height: 20),
                          buildSectionLabel(
                            context,
                            AppStrings.tr('assigned_role_section'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: roleController,
                            decoration:
                                _inputStyle(
                                  context,
                                  Theme.of(context).colorScheme.primary,
                                  'role',
                                ).copyWith(
                                  hintText: AppStrings.tr('enter_role_title'),
                                  prefixIcon: Icon(
                                    Icons.shield_outlined,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                AppStrings.tr('discard'),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                _controller.updateUserStatus(
                                  user.uid,
                                  selectedStatus,
                                );
                                _controller.updateUserRole(
                                  user.uid,
                                  roleController.text.trim(),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                AppStrings.tr('save_changes'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context, UserEmployee user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final statusColor = user.status == 'active'
            ? AppColors.success
            : user.status == 'suspended'
            ? AppColors.error
            : AppColors.secondary;

        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        foregroundImage: NetworkImage(user.profileUrl),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          _initials(user.displayName),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                infoChip(
                                  context,
                                  user.roleTitle,
                                  Icons.badge_rounded,
                                ),
                                statusChip(
                                  context,
                                  _statusLabel(user.status),
                                  statusColor,
                                ),
                                infoChip(
                                  context,
                                  user.departmentId,
                                  Icons.apartment_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(context, AppStrings.tr('contact_section')),
                      const SizedBox(height: 10),
                      infoCard(
                        context,
                        children: [
                          detailRow(
                            context,
                            AppStrings.tr('email_label'),
                            user.email,
                          ),
                          detailRow(
                            context,
                            AppStrings.tr('phone_label'),
                            user.phone.isEmpty
                                ? AppStrings.tr('pending')
                                : user.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      sectionTitle(context, AppStrings.tr('account_section')),
                      const SizedBox(height: 10),
                      infoCard(
                        context,
                        children: [
                          detailRow(
                            context,
                            AppStrings.tr('user_id_label'),
                            user.uid,
                          ),
                          detailRow(
                            context,
                            AppStrings.tr('office_label'),
                            user.officeId,
                          ),
                          detailRow(
                            context,
                            AppStrings.tr('face_status_label'),
                            _faceStatusLabel(user.faceStatus),
                          ),
                          detailRow(
                            context,
                            AppStrings.tr('join_date_label'),
                            _formatDate(user.joinDate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppStrings.tr('close'),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
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
    );
  }

  InputDecoration _inputStyle(
    BuildContext context,
    Color accentColor,
    String type,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
      prefixIcon: type == 'role'
          ? null
          : Icon(
              type == 'active'
                  ? Icons.check_circle_rounded
                  : type == 'suspended'
                  ? Icons.block_rounded
                  : Icons.pause_circle_rounded,
              color: accentColor,
              size: 20,
            ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentColor.withOpacity(0.5), width: 2),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, UserEmployee user) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: const Text(
                'Confirm Deletion',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to remove this user? This profile and all associated data will be lost.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.error.withOpacity(0.2),
                          child: Text(
                            user.displayName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'ID: ${user.uid}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
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
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Keep User',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.removeUser(user.uid);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController uidController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController roleController = TextEditingController();

    bool uidEdited = false;
    bool emailEdited = false;
    String selectedDepartment = _controller.getAllDepartments().isNotEmpty
        ? _controller.getAllDepartments().first
        : 'it';
    String selectedOffice = 'hq_phnom_penh_01';
    String selectedStatus = 'active';

    void updateAutoFields(String name) {
      if (name.trim().isEmpty) return;
      if (!uidEdited) uidController.text = _buildUserId(name);
      if (!emailEdited) emailController.text = _buildEmail(name);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDesktop = MediaQuery.of(context).size.width > 600;

        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: 600,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.tr('create_user_title'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.tr('create_user_subtitle'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),

                    // --- Scrollable Form Body ---
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSectionLabelCreate(
                                context,
                                AppStrings.tr('identity_information'),
                                Icons.badge_outlined,
                              ),
                              const SizedBox(height: 16),

                              buildTextField(
                                context,
                                label: AppStrings.tr('full_name_label'),
                                controller: nameController,
                                hint: AppStrings.tr('full_name_hint'),
                                icon: Icons.person_rounded,
                                validator: (v) => v?.isEmpty == true
                                    ? AppStrings.tr('name_required')
                                    : null,
                                onChanged: (val) =>
                                    setState(() => updateAutoFields(val)),
                              ),
                              const SizedBox(height: 16),

                              buildTextField(
                                context,
                                label: AppStrings.tr('role_title_label'),
                                controller: roleController,
                                hint: AppStrings.tr('role_title_hint'),
                                icon: Icons.work_rounded,
                                validator: (v) => v?.isEmpty == true
                                    ? AppStrings.tr('role_required')
                                    : null,
                              ),
                              const SizedBox(height: 24),

                              buildSectionLabelCreate(
                                context,
                                AppStrings.tr('contact_system_section'),
                                Icons.perm_contact_calendar_outlined,
                              ),
                              const SizedBox(height: 16),

                              Flex(
                                direction: isDesktop
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: isDesktop ? 1 : 0,
                                    child: buildTextField(
                                      context,
                                      label: AppStrings.tr('email_label'),
                                      controller: emailController,
                                      hint: AppStrings.tr('generated_auto'),
                                      icon: Icons.email_rounded,
                                      readOnly: true,
                                      isSystemGenerated: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Flex(
                                direction: isDesktop
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: isDesktop ? 1 : 0,
                                    child: buildDropdown(
                                      context,
                                      label: AppStrings.tr('department_label'),
                                      value: selectedDepartment,
                                      items: _controller.getAllDepartments(),
                                      onChanged: (val) => setState(
                                        () => selectedDepartment = val!,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isDesktop ? 16 : 0,
                                    height: isDesktop ? 0 : 16,
                                  ),
                                  Expanded(
                                    flex: isDesktop ? 1 : 0,
                                    child: buildDropdown(
                                      context,
                                      label: AppStrings.tr('status_label'),
                                      value: selectedStatus,
                                      items: [
                                        'active',
                                        'inactive',
                                        'suspended',
                                      ],
                                      onChanged: (val) =>
                                          setState(() => selectedStatus = val!),
                                      isStatus: true,
                                      statusLabel: _statusLabel,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              buildTextField(
                                context,
                                label: AppStrings.tr('system_id_label'),
                                controller: uidController,
                                hint: AppStrings.tr('generated_auto'),
                                icon: Icons.fingerprint_rounded,
                                readOnly: true,
                                isSystemGenerated: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),

                    // --- Actions Footer ---
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            child: Text(AppStrings.tr('cancel')),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                _controller.createUser(
                                  uid: uidController.text,
                                  displayName: nameController.text,
                                  roleTitle: roleController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  departmentId: selectedDepartment,
                                  officeId: selectedOffice,
                                  status: selectedStatus,
                                );

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'User "${nameController.text}" created successfully',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    showCloseIcon: true,
                                  ),
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(AppStrings.tr('create_user')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
