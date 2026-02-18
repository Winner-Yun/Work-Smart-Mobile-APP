import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';

class AdminSystemSettingsScreen extends StatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  State<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState extends State<AdminSystemSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _notificationsEnabled = true;
  bool _emailSummaries = false;
  bool _securityAlerts = true;
  bool _autoApprove = false;

  void _navigateTo(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (mounted) Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeManager(), LanguageManager()]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            final isCompact = !isDesktop;
            final isDarkMode = ThemeManager().isDarkMode;

            final mainContent = Column(
              children: [
                AdminHeaderBar(_scaffoldKey, isCompact: isCompact),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isCompact ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(),
                        const SizedBox(height: 24),
                        _buildSettingsGrid(isCompact, isDarkMode),
                      ],
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
                        settingsSelected: true,
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
                        onAnalyticsTap: () =>
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
                      settingsSelected: true,
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
                      onAnalyticsTap: () =>
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

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tr('system_settings'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.tr('admin_settings_subtitle'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGrid(bool isCompact, bool isDarkMode) {
    final cards = [
      _buildSectionCard(
        title: AppStrings.tr('admin_settings_general'),
        subtitle: AppStrings.tr('admin_settings_general_subtitle'),
        icon: Icons.tune_rounded,
        child: Column(
          children: [
            _buildInfoTile(
              label: AppStrings.tr('admin_settings_language'),
              value: LanguageManager().locale.toUpperCase(),
              actionLabel: AppStrings.tr('admin_settings_switch'),
              onAction: () {
                LanguageManager().changeLanguage(
                  LanguageManager().locale == 'en' ? 'km' : 'en',
                );
              },
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              label: AppStrings.tr('admin_settings_timezone'),
              value: 'Asia/Phnom_Penh',
            ),
          ],
        ),
      ),
      _buildSectionCard(
        title: AppStrings.tr('admin_settings_appearance'),
        subtitle: AppStrings.tr('admin_settings_appearance_subtitle'),
        icon: Icons.palette_rounded,
        child: Column(
          children: [
            _buildSwitchTile(
              label: AppStrings.tr('admin_settings_dark_mode'),
              description: AppStrings.tr('admin_settings_dark_mode_desc'),
              value: isDarkMode,
              onChanged: (val) => ThemeManager().toggleTheme(val),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              label: AppStrings.tr('admin_settings_density'),
              value: AppStrings.tr('admin_settings_density_comfortable'),
            ),
          ],
        ),
      ),
      _buildSectionCard(
        title: AppStrings.tr('admin_settings_notifications'),
        subtitle: AppStrings.tr('admin_settings_notifications_subtitle'),
        icon: Icons.notifications_active_rounded,
        child: Column(
          children: [
            _buildSwitchTile(
              label: AppStrings.tr('admin_settings_enable_notifications'),
              description: AppStrings.tr(
                'admin_settings_enable_notifications_desc',
              ),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() {
                _notificationsEnabled = val;
              }),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              label: AppStrings.tr('admin_settings_email_summaries'),
              description: AppStrings.tr('admin_settings_email_summaries_desc'),
              value: _emailSummaries,
              onChanged: (val) => setState(() {
                _emailSummaries = val;
              }),
            ),
          ],
        ),
      ),
      _buildSectionCard(
        title: AppStrings.tr('admin_settings_security'),
        subtitle: AppStrings.tr('admin_settings_security_subtitle'),
        icon: Icons.shield_rounded,
        child: Column(
          children: [
            _buildSwitchTile(
              label: AppStrings.tr('admin_settings_security_alerts'),
              description: AppStrings.tr('admin_settings_security_alerts_desc'),
              value: _securityAlerts,
              onChanged: (val) => setState(() {
                _securityAlerts = val;
              }),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              label: AppStrings.tr('admin_settings_auto_approve'),
              description: AppStrings.tr('admin_settings_auto_approve_desc'),
              value: _autoApprove,
              onChanged: (val) => setState(() {
                _autoApprove = val;
              }),
            ),
          ],
        ),
      ),
    ];

    if (isCompact) {
      return Column(
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: card,
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 20),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 20),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08);
  }

  Widget _buildSwitchTile({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
