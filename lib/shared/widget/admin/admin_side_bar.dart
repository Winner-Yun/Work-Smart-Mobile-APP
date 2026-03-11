import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';

class AdminSideBar extends StatelessWidget {
  final bool isCompact;
  final bool dashboardSelected,
      staffSelected,
      geofencingSelected,
      leaderboardSelected,
      leaverequestsSelected,
      analyticsSelected,
      faceReviewSelected,
      attendentRecordSelected,
      settingsSelected;
  final VoidCallback? onDashboardTap,
      onStaffTap,
      onGeofencingTap,
      onLeaderboardTap,
      onLeaveRequestsTap,
      onAnalyticsTap,
      onFaceReviewTap,
      onAttendentRecordTap,
      onSettingsTap;

  const AdminSideBar({
    super.key,
    this.isCompact = false,
    this.dashboardSelected = false,
    this.staffSelected = false,
    this.geofencingSelected = false,
    this.leaderboardSelected = false,
    this.leaverequestsSelected = false,
    this.analyticsSelected = false,
    this.faceReviewSelected = false,
    this.attendentRecordSelected = false,
    this.settingsSelected = false,
    this.onDashboardTap,
    this.onStaffTap,
    this.onGeofencingTap,
    this.onLeaderboardTap,
    this.onLeaveRequestsTap,
    this.onAnalyticsTap,
    this.onFaceReviewTap,
    this.onAttendentRecordTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSidebar(context);
  }

  Widget _buildSidebar(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.6);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Image.asset(
                  ThemeManager().isDarkMode
                      ? AppImg.appIconDark
                      : AppImg.appIcon,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  "WorkSmart",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildNavItem(
            context,
            Icons.dashboard_rounded,
            AppStrings.tr('admin_homepage'),
            dashboardSelected,
            onDashboardTap,
          ),
          _buildNavItem(
            context,
            Icons.people_alt_rounded,
            AppStrings.tr('staff_management'),
            staffSelected,
            onStaffTap,
          ),
          _buildNavItem(
            context,
            Icons.verified_user_rounded,
            AppStrings.tr('face_review_menu'),
            faceReviewSelected,
            onFaceReviewTap,
            fallbackRouteName: AppAdminRoute.manualFaceReview,
          ),
          _buildNavItem(
            context,
            Icons.location_on_rounded,
            AppStrings.tr('geofencing'),
            geofencingSelected,
            onGeofencingTap,
          ),
          _buildNavItem(
            context,
            Icons.bar_chart_rounded,
            AppStrings.tr('performance_leaderboard'),
            leaderboardSelected,
            onLeaderboardTap,
          ),
          _buildNavItem(
            context,
            Icons.event_note_rounded,
            AppStrings.tr('leaverequests'),
            leaverequestsSelected,
            onLeaveRequestsTap,
          ),
          _buildNavItem(
            context,
            Icons.fact_check_rounded,
            AppStrings.tr('attendent_record'),
            attendentRecordSelected,
            onAttendentRecordTap,
            fallbackRouteName: AppAdminRoute.attendentRecord,
          ),
          _buildNavItem(
            context,
            Icons.description_rounded,
            AppStrings.tr('analytics'),
            analyticsSelected,
            onAnalyticsTap,
          ),
          _buildNavItem(
            context,
            Icons.settings_rounded,
            AppStrings.tr('system_settings'),
            settingsSelected,
            onSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback? onTap, {
    String? fallbackRouteName,
  }) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : Colors.transparent;
    final textColor = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface.withOpacity(0.6);
    final resolvedOnTap =
        onTap ??
        (fallbackRouteName == null
            ? null
            : () => Navigator.of(context).pushNamed(fallbackRouteName));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: resolvedOnTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: isActive
              ? theme.colorScheme.primary.withOpacity(0.8)
              : theme.colorScheme.primary.withOpacity(0.1),
          child: ListTile(
            minLeadingWidth: 20,
            leading: Icon(icon, color: textColor),
            title: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
