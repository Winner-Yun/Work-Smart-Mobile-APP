import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/attendent_record_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';

class AttendentRecordScreen extends StatefulWidget {
  const AttendentRecordScreen({super.key});

  @override
  State<AttendentRecordScreen> createState() => _AttendentRecordScreenState();
}

class _AttendentRecordScreenState extends State<AttendentRecordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AttendentRecordController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = AttendentRecordController();
    _searchController = TextEditingController();
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateTo(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (mounted) {
      Navigator.of(context).pushNamed(routeName);
    }
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

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              drawer: isCompact ? Drawer(child: _buildSidebar(true)) : null,
              body: Row(
                children: [
                  if (isDesktop) _buildSidebar(false),
                  Expanded(
                    child: Column(
                      children: [
                        AdminHeaderBar(_scaffoldKey, isCompact: isCompact),
                        Expanded(child: _buildContent(isCompact)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSidebar(bool isCompact) {
    return AdminSideBar(
      isCompact: isCompact,
      attendentRecordSelected: true,
      onDashboardTap: () => _navigateTo(AppAdminRoute.adminDashboard),
      onStaffTap: () => _navigateTo(AppAdminRoute.staffManagement),
      onGeofencingTap: () => _navigateTo(AppAdminRoute.geofencing),
      onLeaderboardTap: () => _navigateTo(AppAdminRoute.performanceLeaderboard),
      onLeaveRequestsTap: () => _navigateTo(AppAdminRoute.leaveRequests),
      onAnalyticsTap: () => _navigateTo(AppAdminRoute.analyticsReports),
      onFaceReviewTap: () => _navigateTo(AppAdminRoute.manualFaceReview),
      onAttendentRecordTap: () => _navigateTo(AppAdminRoute.attendentRecord),
      onSettingsTap: () => _navigateTo(AppAdminRoute.systemSettings),
    );
  }

  Widget _buildContent(bool isCompact) {
    final summary = _controller.summary;
    final rows = _controller.filteredRows;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        children: [
          _buildHeader(isCompact),
          const SizedBox(height: 16),
          _buildSummarySection(summary),
          const SizedBox(height: 16),
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          if (_controller.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _controller.errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _controller.refresh,
                    tooltip: AppStrings.tr('retry'),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          if (_controller.isLoading && !_controller.hasAnyRows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(AppStrings.tr('loading')),
                  ],
                ),
              ),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                AppStrings.tr('no_attendance_data_available'),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ...rows.map(_buildRecordCard),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final textTheme = Theme.of(context).textTheme;
    final selectedDateText = _formatDate(_controller.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tr('attendent_record'),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isCompact ? 24 : 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.tr('attendent_record_subtitle'),
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(AppStrings.tr('select_date')),
            ),
            IconButton(
              onPressed: () => _controller.shiftSelectedDateBy(-1),
              tooltip: AppStrings.tr('previous_day'),
              icon: const Icon(Icons.chevron_left_rounded),
              visualDensity: VisualDensity.compact,
            ),
            _buildDatePill(selectedDateText),
            if (!_controller.isToday)
              OutlinedButton(
                onPressed: () => _controller.setSelectedDate(DateTime.now()),
                child: Text(AppStrings.tr('today')),
              ),
            IconButton(
              onPressed: () => _controller.shiftSelectedDateBy(1),
              tooltip: AppStrings.tr('next_day'),
              icon: const Icon(Icons.chevron_right_rounded),
              visualDensity: VisualDensity.compact,
            ),

            IconButton(
              onPressed: _controller.refresh,
              tooltip: AppStrings.tr('refresh'),
              icon: const Icon(Icons.refresh_rounded),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSummarySection(AttendanceSummary summary) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildSummaryCard(
          label: AppStrings.tr('total_employees'),
          value: '${summary.totalEmployees}',
          icon: Icons.groups_rounded,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          label: AppStrings.tr('present'),
          value: '${summary.presentCount}',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        ),
        _buildSummaryCard(
          label: AppStrings.tr('late'),
          value: '${summary.lateCount}',
          icon: Icons.schedule_rounded,
          color: Colors.orange,
        ),
        _buildSummaryCard(
          label: AppStrings.tr('absent'),
          value: '${summary.absentCount}',
          icon: Icons.cancel_rounded,
          color: Colors.red,
        ),
        _buildSummaryCard(
          label: AppStrings.tr('avg_hours'),
          value: summary.averageHours.toStringAsFixed(1),
          icon: Icons.timelapse_rounded,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 145, maxWidth: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: AppStrings.tr('attendent_record_search_hint'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _controller.setSearchQuery('');
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.35),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildDepartmentDropdown(),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('all', AppStrings.tr('all')),
            _buildFilterChip('present', AppStrings.tr('present')),
            _buildFilterChip('late', AppStrings.tr('late')),
            _buildFilterChip('absent', AppStrings.tr('absent')),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    final theme = Theme.of(context);
    final departments = _controller.availableDepartmentIds;
    final selectedDepartment =
        departments.contains(_controller.departmentFilter)
        ? _controller.departmentFilter
        : 'all';

    return DropdownButtonFormField<String>(
      value: selectedDepartment,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AppStrings.tr('department_label'),
        prefixIcon: const Icon(Icons.apartment_rounded),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.35)),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(AppStrings.tr('all_departments')),
        ),
        ...departments.map(
          (departmentId) =>
              DropdownMenuItem(value: departmentId, child: Text(departmentId)),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        _controller.setDepartmentFilter(value);
      },
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _controller.statusFilter == value,
      onSelected: (_) => _controller.setStatusFilter(value),
    );
  }

  Widget _buildRecordCard(AttendentRecordRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showRecordDetails(row),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              foregroundImage: row.profileUrl.trim().isEmpty
                  ? null
                  : NetworkImage(row.profileUrl),
              child: Text(_initialFor(row.name)),
            ),
            title: Text(
              row.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${AppStrings.tr('check_in_time')}: ${row.checkIn}   '
              '${AppStrings.tr('check_out_time')}: ${row.checkOut}\n'
              '${AppStrings.tr('total_hours')}: ${row.totalHours.toStringAsFixed(1)}',
            ),
            isThreeLine: true,
            trailing: _buildStatusChip(row.status),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase();
    final theme = Theme.of(context);

    Color background;
    Color foreground;

    if (normalized == 'present' || normalized == 'on_time') {
      background = Colors.green.withOpacity(0.14);
      foreground = Colors.green.shade700;
    } else if (normalized == 'late') {
      background = Colors.orange.withOpacity(0.14);
      foreground = Colors.orange.shade800;
    } else {
      background = theme.colorScheme.error.withOpacity(0.12);
      foreground = theme.colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusText(normalized),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'present':
      case 'on_time':
        return AppStrings.tr('present');
      case 'late':
        return AppStrings.tr('late');
      case 'absent':
      default:
        return AppStrings.tr('absent');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );

    if (picked == null) return;
    _controller.setSelectedDate(picked);
  }

  void _showRecordDetails(AttendentRecordRow row) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final locationValue = (row.lat == null || row.lng == null)
            ? '-'
            : '${row.lat!.toStringAsFixed(5)}, ${row.lng!.toStringAsFixed(5)}';
        var locationCopied = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.12),
                            foregroundImage: row.profileUrl.trim().isEmpty
                                ? null
                                : NetworkImage(row.profileUrl),
                            child: Text(
                              _initialFor(row.name),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  row.uid,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.68),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildStatusChip(row.status),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: AppStrings.tr('close'),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(_controller.selectedDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        AppStrings.tr('employee'),
                        row.uid,
                        icon: Icons.badge_rounded,
                      ),
                      _buildDetailRow(
                        AppStrings.tr('check_in_time'),
                        row.checkIn,
                        icon: Icons.login_rounded,
                      ),
                      _buildDetailRow(
                        AppStrings.tr('check_out_time'),
                        row.checkOut,
                        icon: Icons.logout_rounded,
                      ),
                      _buildDetailRow(
                        AppStrings.tr('total_hours'),
                        row.totalHours.toStringAsFixed(1),
                        icon: Icons.timelapse_rounded,
                      ),
                      _buildDetailRow(
                        AppStrings.tr('location_label'),
                        locationValue,
                        icon: Icons.place_rounded,
                        canCopy: locationValue != '-',
                        isCopied: locationCopied,
                        onCopy: () {
                          if (locationCopied) return;

                          unawaited(
                            _copyText(locationValue).then((_) {
                              if (!dialogContext.mounted) return;
                              setDialogState(() => locationCopied = true);
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    bool canCopy = false,
    bool isCopied = false,
    VoidCallback? onCopy,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.62),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              onPressed: onCopy ?? () => unawaited(_copyText(value)),
              tooltip: AppStrings.tr('copy'),
              icon: Icon(
                isCopied ? Icons.check_rounded : Icons.copy_rounded,
                size: 18,
                color: isCopied
                    ? Colors.green.shade700
                    : theme.colorScheme.primary,
              ),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Future<void> _copyText(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _initialFor(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '?';
    return normalized.characters.first.toUpperCase();
  }
}
