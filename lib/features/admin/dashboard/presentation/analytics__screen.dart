import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/analytics__logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = AnalyticsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateTo(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (mounted) Navigator.of(context).pushNamed(routeName);
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
        final theme = Theme.of(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            final isTablet = constraints.maxWidth >= 700 && !isDesktop;
            final isCompact = !isDesktop && !isTablet;

            final mainContent = Column(
              children: [
                AdminHeaderBar(_scaffoldKey, isCompact: !isDesktop),
                Expanded(
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 16 : 32,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopControls(isCompact),
                              const SizedBox(height: 32),
                              _buildModernMetricSelector(isCompact),
                              const SizedBox(height: 32),

                              // Main Layout Grid
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: ScaleTransition(
                                              scale:
                                                  Tween<double>(
                                                    begin: 0.95,
                                                    end: 1.0,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _buildMainChartSection(),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 4,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position:
                                                  Tween<Offset>(
                                                    begin: const Offset(0.2, 0),
                                                    end: Offset.zero,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _buildSummaryCards(),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(0, 0.2),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _buildSummaryCards(),
                                    ),
                                    const SizedBox(height: 24),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale:
                                                Tween<double>(
                                                  begin: 0.95,
                                                  end: 1.0,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _buildMainChartSection(),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                        // Loading Overlay
                        if (_controller.isLoading)
                          AnimatedOpacity(
                            opacity: _controller.isLoading ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              color: theme.colorScheme.surface.withOpacity(0.7),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppStrings.tr('loading_analytics'),
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: theme.scaffoldBackgroundColor,
              drawer: !isDesktop
                  ? Drawer(
                      width: 250,
                      child: AdminSideBar(
                        isCompact: true,
                        analyticsSelected: true,
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
                      analyticsSelected: true,
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

  // --- Section 1: Top Controls ---

  Widget _buildTopControls(bool isCompact) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('analytics_title'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.tr('deep_dive_workforce_metrics'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompact)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildPeriodButton('week'),
                    _buildPeriodButton('month'),
                    _buildPeriodButton('quarter'),
                  ],
                ),
              ),
          ],
        ),
        if (!isCompact && _controller.selectedPeriod == 'month')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildMonthYearSelector(),
          ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildMonthYearSelector() {
    final months = [
      AppStrings.tr('month_january'),
      AppStrings.tr('month_february'),
      AppStrings.tr('month_march'),
      AppStrings.tr('month_april'),
      AppStrings.tr('month_mayy'),
      AppStrings.tr('month_june'),
      AppStrings.tr('month_july'),
      AppStrings.tr('month_august'),
      AppStrings.tr('month_september'),
      AppStrings.tr('month_october'),
      AppStrings.tr('month_november'),
      AppStrings.tr('month_december'),
    ];
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: DropdownButton<int>(
            value: _controller.selectedMonth,
            isExpanded: true,
            underline: SizedBox(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: theme.cardColor,
            items: months.asMap().entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key + 1,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _controller.changeMonth(value);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
          ),
          child: Text(
            _controller.selectedYear.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () => _controller.changeYear(_controller.selectedYear - 1),
            child: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () => _controller.changeYear(_controller.selectedYear + 1),
            child: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildPeriodButton(String value) {
    final isSelected = _controller.selectedPeriod == value;
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _controller.changePeriod(value),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: 250.ms,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            AppStrings.tr('period_$value'),
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // --- Section 2: Metric Selector (Tabs) ---

  Widget _buildModernMetricSelector(bool isCompact) {
    final metrics = [
      {
        'id': 'attendance',
        'icon': Icons.access_time_filled,
        'label': 'Attendance',
      },
      {
        'id': 'performance',
        'icon': Icons.bar_chart_rounded,
        'label': 'Performance',
      },
      {'id': 'leaves', 'icon': Icons.calendar_month_rounded, 'label': 'Leaves'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: metrics.map((m) {
          final isSelected = _controller.selectedMetric == m['id'];
          final theme = Theme.of(context);
          final primaryColor = theme.colorScheme.primary;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _controller.changeMetric(m['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : theme.dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        m['icon'] as IconData,
                        size: isSelected ? 22 : 20,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.iconTheme.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontSize: isSelected ? 15 : 14,
                      ),
                      child: Text(m['label'] as String),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Section 3: Main Chart ---

  Widget _buildMainChartSection() {
    final chartData = _controller.getChartData();
    final theme = Theme.of(context);

    return Container(
      key: ValueKey(_controller.selectedMetric),
      height: 440, // Optimized height
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_controller.selectedMetric.toUpperCase()} ${AppStrings.tr('overview')}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.tr('visual_breakdown'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                  color: theme.colorScheme.onSurfaceVariant,
                  splashRadius: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(child: _buildModernBarChart(chartData)),
        ],
      ),
    ).animate().fadeIn().scale(delay: 100.ms, curve: Curves.easeOut);
  }

  // --- Section 4: Summary Cards (Grid) ---

  Widget _buildSummaryCards() {
    final data = _controller.getMetricData();
    List<Widget> cards = [];

    Widget mkCard(String title, String val, String trend, Color c, IconData i) {
      return _buildStatCard(
        title: title,
        value: val,
        trend: trend,
        color: c,
        icon: i,
      );
    }

    if (_controller.selectedMetric == 'attendance') {
      cards = [
        mkCard(
          AppStrings.tr('card_presence_rate'),
          '${data['presentRate'].toStringAsFixed(1)}%',
          '+${data['presentTrend']}%',
          AppColors.success,
          Icons.check_circle_outline,
        ),
        mkCard(
          AppStrings.tr('card_total_absent'),
          '${data['absentDays']}',
          '${data['absentTrend']}%',
          AppColors.error,
          Icons.cancel_outlined,
        ),
        mkCard(
          AppStrings.tr('card_late_arrivals'),
          '${data['lateDays']}',
          '+${data['lateTrend']}%',
          Colors.orange,
          Icons.timer_outlined,
        ),
        mkCard(
          AppStrings.tr('card_employees'),
          '${data['totalEmployees']}',
          '0%',
          Colors.blue,
          Icons.groups_outlined,
        ),
      ];
    } else if (_controller.selectedMetric == 'performance') {
      cards = [
        mkCard(
          AppStrings.tr('card_avg_score'),
          data['avgScore'].toStringAsFixed(1),
          '+${data['avgScoreTrend']}%',
          Colors.purple,
          Icons.score,
        ),
        mkCard(
          AppStrings.tr('card_high_performers'),
          '${data['highPerformers']}',
          '+${data['highTrend']}%',
          Colors.indigo,
          Icons.star,
        ),
        mkCard(
          AppStrings.tr('card_improving'),
          '${data['improving']}',
          '+5%',
          Colors.green,
          Icons.trending_up,
        ),
        mkCard(
          AppStrings.tr('card_low_performers'),
          '${data['lowPerformers']}',
          '${data['lowTrend']}%',
          Colors.red,
          Icons.warning_amber,
        ),
      ];
    } else {
      cards = [
        mkCard(
          AppStrings.tr('card_total_staff'),
          '${data['totalEmployees']}',
          '0%',
          Colors.blueGrey,
          Icons.person,
        ),
        mkCard(
          AppStrings.tr('card_active'),
          '${(data['totalEmployees'] * 0.8).toInt()}',
          '+2%',
          Colors.teal,
          Icons.bolt,
        ),
        mkCard(
          AppStrings.tr('card_pending'),
          '5',
          '-10%',
          Colors.amber,
          Icons.pending_actions,
        ),
        mkCard(
          AppStrings.tr('card_issues'),
          '0',
          '0%',
          Colors.green,
          Icons.check,
        ),
      ];
    }

    // A GridView is much more professional and scalable than a Wrap
    return GridView.count(
      key: ValueKey(_controller.selectedMetric),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15, // Balances width and height perfectly
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Transform.scale(
              scale: 0.85 + (value * 0.15),
              child: Opacity(opacity: value, child: card),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required Color color,
    required IconData icon,
  }) {
    final isNegative = trend.startsWith('-');
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNegative
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNegative
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 12,
                      color: isNegative ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend.replaceAll(RegExp(r'[+-]'), ''), // Clean the sign
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isNegative ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn().scale(delay: 50.ms);
  }

  Widget _buildModernBarChart(List<ChartDataPoint> data) {
    if (data.isEmpty) return Center(child: Text(AppStrings.tr('no_data')));

    final maxValue = data.map((e) => e.value).reduce(max);
    final safeMax = maxValue == 0 ? 1 : maxValue;
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Background Grid Lines
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Divider(
                  color: theme.dividerColor.withOpacity(0.1),
                  thickness: 1,
                ),
              ),
            );
          }),
        ),

        // Foreground Bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.asMap().entries.map((entry) {
            final item = entry.value;
            final index = entry.key;
            final heightFactor = item.value / safeMax;

            return Column(
              children: [
                SizedBox(
                  height: 28,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child:
                        Text(
                              '${item.value}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (300 + index * 100).ms)
                            .slideY(begin: 0.5, end: 0),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Track background (Empty Bar)
                      Container(
                        width: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Animated Fill
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: heightFactor),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutQuart,
                        builder: (context, val, _) {
                          return FractionallySizedBox(
                            heightFactor: val == 0 ? 0.01 : val,
                            child: Container(
                              width: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    item.color.withOpacity(0.7),
                                    item.color,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.color.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 24,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
