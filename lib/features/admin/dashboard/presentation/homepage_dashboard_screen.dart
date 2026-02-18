import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/map_styles.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Logic & State
  late final DashboardController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _attendanceSearchQuery = '';
  String _sortBy = 'name'; // Default sort

  // Map Specifics
  late final OfficeConfig _officeConfig;
  late final gmaps.LatLng _officeLocation;
  gmaps.GoogleMapController? _mapController;

  // Hover State
  final bool _isProfileHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _officeConfig = getOfficeConfig();
    _officeLocation = gmaps.LatLng(
      _officeConfig.geofence.lat,
      _officeConfig.geofence.lng,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMapStyle();
  }

  void _applyMapStyle() {
    if (_mapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _mapController!.setMapStyle(isDark ? MapStyles.dark : null);
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ==========================================
  // MAIN BUILD METHOD
  // ==========================================
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
            // Responsive Breakpoints
            final isDesktop = constraints.maxWidth >= 1100;

            final isCompact = !isDesktop;

            final mainContent = Column(
              children: [
                AdminHeaderBar(_scaffoldKey, isCompact: !isDesktop),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(isCompact ? 16 : 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsGrid(isCompact),
                            SizedBox(height: isCompact ? 20 : 32),

                            // Tables/Map
                            if (isDesktop)
                              Column(
                                children: [
                                  _buildAttendanceTable(),
                                  const SizedBox(height: 32),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildGeofenceCard()),
                                      const SizedBox(width: 32),
                                      Expanded(child: _buildTopPerformers()),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildAttendanceTable(),
                                  const SizedBox(height: 32),
                                  _buildRightPanel(),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Loading Overlay
                      if (_controller.isLoading)
                        AnimatedOpacity(
                          opacity: _controller.isLoading ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.7),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
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
              ],
            );

            return Scaffold(
              key: _scaffoldKey,
              drawer: isCompact
                  ? Drawer(
                      child: AdminSideBar(
                        isCompact: true,
                        dashboardSelected: true,
                        onDashboardTap: () =>
                            _navigateTo(AppAdminRoute.adminDashboard),
                        onStaffTap: () =>
                            _navigateTo(AppAdminRoute.staffManagement),
                        onLeaveRequestsTap: () =>
                            _navigateTo(AppAdminRoute.leaveRequests),
                        onGeofencingTap: () =>
                            _navigateTo(AppAdminRoute.geofencing),
                        onLeaderboardTap: () =>
                            _navigateTo(AppAdminRoute.performanceLeaderboard),
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
                      dashboardSelected: true,
                      onDashboardTap: () =>
                          _navigateTo(AppAdminRoute.adminDashboard),
                      onStaffTap: () =>
                          _navigateTo(AppAdminRoute.staffManagement),
                      onLeaveRequestsTap: () =>
                          _navigateTo(AppAdminRoute.leaveRequests),
                      onGeofencingTap: () =>
                          _navigateTo(AppAdminRoute.geofencing),
                      onLeaderboardTap: () =>
                          _navigateTo(AppAdminRoute.performanceLeaderboard),
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

  // ==========================================
  // UI SECTIONS (The "One Class" approach)
  // ==========================================

  // --- 2. Header ---

  // --- 3. Statistics Grid ---
  Widget _buildStatsGrid(bool isCompact) {
    final stats = buildDashboardStats();

    // Helper to create a single card
    Widget makeCard(
      String label,
      String val,
      String sub,
      IconData icon,
      Color color, {
      double? progress,
      bool isAlert = false,
    }) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.6),
          ),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (progress == null && !isAlert)
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  val,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 30,
                    height: 30,

                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: progress),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOutExpo,
                      builder: (context, animatedValue, _) {
                        return CircularProgressIndicator(
                          value: animatedValue,
                          strokeWidth: 3,
                          backgroundColor: color.withOpacity(0.1),
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            if (progress != null || isAlert)
              Text(
                sub,
                style: TextStyle(
                  color: isAlert
                      ? AppColors.error
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
      );
    }

    final cards = [
      makeCard(
        AppStrings.tr('total_employees'),
        stats.totalEmployees.toString(),
        "${AppStrings.tr('present')}: ${stats.presentCount}",
        Icons.group,
        AppColors.tertiary,
        progress: stats.presentCount / stats.totalEmployees,
      ).animate().fade().slideY(begin: 0.2),
      makeCard(
        AppStrings.tr('present_today'),
        "${(stats.presentRate * 100).toStringAsFixed(0)}%",
        "${stats.presentCount} ${AppStrings.tr('checked_in')}",
        Icons.check_circle,
        AppColors.success,
        progress: stats.presentRate,
      ).animate().fade().slideY(begin: 0.2),
      makeCard(
        AppStrings.tr('ontime_vs_late'),
        stats.onTimeCount.toString(),
        "/ ${stats.lateCount} ${AppStrings.tr('late_count')}",
        Icons.timer,
        AppColors.secondary,
        progress: stats.onTimeRate,
      ),
      makeCard(
        AppStrings.tr('pending_requests'),
        stats.pendingRequests.toString(),
        AppStrings.tr('requires_attention'),
        Icons.shield,
        AppColors.error,
        isAlert: true,
      ).animate().fade().slideY(begin: 0.2),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;
        final isTablet = constraints.maxWidth >= 700;

        if (isDesktop) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0);
        } else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 20),
                      child: cards[0],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 20),
                      child: cards[1],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: cards[2],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: cards[3],
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.1, end: 0);
        } else {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: card,
                  ),
                )
                .toList(),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0);
        }
      },
    );
  }

  // ---  Attendance Table ---
  Widget _buildAttendanceTable() {
    final allRows = buildAttendanceRows(limit: 100);

    var filteredRows = _attendanceSearchQuery.isEmpty
        ? allRows.take(5).toList()
        : allRows
              .where(
                (row) =>
                    row.name.toLowerCase().contains(
                      _attendanceSearchQuery.toLowerCase(),
                    ) ||
                    row.dept.toLowerCase().contains(
                      _attendanceSearchQuery.toLowerCase(),
                    ) ||
                    row.checkIn.toLowerCase().contains(
                      _attendanceSearchQuery.toLowerCase(),
                    ),
              )
              .toList();

    filteredRows = _applySorting(filteredRows);

    Widget header(String text) => Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
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
                    AppStrings.tr('real_time_attendance'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.tr('live_checkin_stream'),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(flex: 2, child: _buildAttendanceSearchField()),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: _buildSortDropdown()),
            ],
          ),
          const SizedBox(height: 16),

          if (_attendanceSearchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredRows.length} ${filteredRows.length == 1 ? AppStrings.tr('result_found') : AppStrings.tr('results_found')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          // Table Header
          Row(
            children: [
              header(AppStrings.tr('employee')),
              header(AppStrings.tr('check_in_time')),
              header(AppStrings.tr('check_out_time')),
              header(AppStrings.tr('status')),
            ],
          ),
          const Divider(height: 24),
          // Show No Results Message
          if (filteredRows.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.tr('no_employees_found'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _attendanceSearchQuery.isEmpty
                          ? AppStrings.tr('no_attendance_data_available')
                          : AppStrings.tr(
                              'try_searching_different_name_or_department',
                            ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
            )
          // Table Rows
          else
            ...filteredRows.map((row) {
              final color = row.isLate
                  ? AppColors.secondary
                  : AppColors.success;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showEmployeeProfile(row);
                      },
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _buildProfileAvatar(
                                    name: row.name,
                                    imageUrl: row.profileUrl,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        row.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        row.dept,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    row.checkIn,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    row.timeStatus,
                                    style: TextStyle(
                                      color: row.isLate
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.secondary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    row.checkOut,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    row.timeStatus,
                                    style: TextStyle(
                                      color: row.isLate
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.secondary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 6, color: color),
                                      const SizedBox(width: 6),
                                      Text(
                                        row.statusLabel,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.donut_large,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- . Right Panel (Map & Top Performers) ---
  Widget _buildRightPanel() {
    return Column(
      children: [
        _buildGeofenceCard(),
        const SizedBox(height: 32),
        _buildTopPerformers(),
      ],
    );
  }

  Widget _buildGeofenceCard() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.map_outlined, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _officeConfig.officeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppStrings.tr('active'),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_city,
            AppStrings.tr('office_address'),
            _officeConfig.geofence.addressLabel,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.radar,
            AppStrings.tr('geofence_radius'),
            '${_officeConfig.geofence.radiusMeters}m',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.people_outline,
            AppStrings.tr('employees_in_range'),
            '${buildDashboardStats().presentCount} ${AppStrings.tr('active')}',
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: _officeLocation,
                  zoom: 15.5,
                ),
                onMapCreated: (c) {
                  _mapController = c;
                  _applyMapStyle();
                },
                markers: {
                  gmaps.Marker(
                    markerId: const gmaps.MarkerId('office'),
                    position: _officeLocation,
                  ),
                },
                circles: {
                  gmaps.Circle(
                    circleId: const gmaps.CircleId('radius'),
                    center: _officeLocation,
                    radius: _officeConfig.geofence.radiusMeters.toDouble(),
                    strokeWidth: 2,
                    strokeColor: primary,
                    fillColor: primary.withOpacity(0.18),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final performers = buildTopPerformers();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.tr('top_performers'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...performers.asMap().entries.map((entry) {
            final p = entry.value;
            final rank = entry.key + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildProfileAvatar(name: p.name, imageUrl: p.profileUrl),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: rank == 1
                              ? Colors.amber
                              : (rank == 2 ? Colors.grey : Colors.brown),
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          p.dept,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        p.score,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        AppStrings.tr('points_label'),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _navigateTo(AppAdminRoute.performanceLeaderboard);
              },
              child: Text(
                AppStrings.tr('view_detailed_leaderboard'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Widget _buildAttendanceSearchField() {
    final primary = Theme.of(context).colorScheme.primary;
    final hasSearchText = _attendanceSearchQuery.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.08), primary.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSearchText
              ? primary.withOpacity(0.4)
              : primary.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: hasSearchText
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _attendanceSearchQuery = value;
          });
        },
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.tr(
            'search_by_employee_name_role_or_check_in_time',
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(Icons.search_rounded, color: primary, size: 22),
          ),
          suffixIcon: hasSearchText
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _attendanceSearchQuery = '';
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: primary.withOpacity(0.2),
                      child: Icon(
                        Icons.close_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        cursorColor: primary,
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildSortDropdown() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.08), primary.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.15), width: 2),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value ?? 'name';
          });
        },
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: Theme.of(context).colorScheme.surface,
        items: [
          DropdownMenuItem(
            value: 'name',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: primary),
                const SizedBox(width: 8),
                const Text('Name (A-Z)', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'name_desc',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: primary),
                const SizedBox(width: 8),
                const Text('Name (Z-A)', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'status',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: primary),
                const SizedBox(width: 8),
                const Text(
                  'Status (Late First)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'status_desc',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: primary),
                const SizedBox(width: 8),
                const Text(
                  'Status (On-time First)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'checkin',
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: primary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.tr('check_in_time'),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  List<AttendanceRowData> _applySorting(List<AttendanceRowData> rows) {
    final sortedRows = List<AttendanceRowData>.from(rows);

    switch (_sortBy) {
      case 'name_desc':
        sortedRows.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'status':
        sortedRows.sort(
          (a, b) => a.isLate == b.isLate
              ? 0
              : a.isLate
              ? -1
              : 1,
        );
        break;
      case 'status_desc':
        sortedRows.sort(
          (a, b) => a.isLate == b.isLate
              ? 0
              : !a.isLate
              ? -1
              : 1,
        );
        break;
      case 'checkin':
        sortedRows.sort((a, b) => a.checkIn.compareTo(b.checkIn));
        break;
      case 'name':
      default:
        sortedRows.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return sortedRows;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar({
    required String name,
    required String imageUrl,
    double radius = 18,
  }) {
    // Helper to generate text avatar if image fails or is empty
    Widget fallback() => CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        getInitials(name),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    if (imageUrl.trim().isEmpty) return fallback();

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) =>
              progress == null ? child : fallback(),
          errorBuilder: (ctx, err, stack) => fallback(),
        ),
      ),
    );
  }

  void _navigateTo(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (mounted) Navigator.of(context).pushNamed(routeName);
  }

  void _showEmployeeProfile(AttendanceRowData employee) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final isLate = employee.isLate;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header with background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.15),
                        primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Avatar
                      _buildProfileAvatar(
                        name: employee.name,
                        imageUrl: employee.profileUrl,
                        radius: 40,
                      ),
                      const SizedBox(height: 16),
                      // Employee Name
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Department
                      Text(
                        employee.dept,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isLate ? secondary : AppColors.success)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isLate ? secondary : AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              employee.statusLabel,
                              style: TextStyle(
                                color: isLate ? secondary : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Details Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Check-in Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  size: 20,
                                  color: primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.tr('check_in_time'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        employee.checkIn,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  employee.timeStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isLate
                                        ? secondary
                                        : AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 20,
                                  color: primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.tr('check_out_time'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        employee.checkOut,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEmployeeDetails(employee);
                              },
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Details'),
                            ),
                          ),
                        ],
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
  }

  void _showEmployeeDetails(AttendanceRowData employee) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final isLate = employee.isLate;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.2),
                        primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      _buildProfileAvatar(
                        name: employee.name,
                        imageUrl: employee.profileUrl,
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.dept,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isLate ? secondary : AppColors.success)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: isLate ? secondary : AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              employee.statusLabel,
                              style: TextStyle(
                                color: isLate ? secondary : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Details Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Time Details Section
                      _buildDetailCard(
                        title: 'Attendance Details',
                        icon: Icons.schedule,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            'Check-in Time',
                            employee.checkIn,
                            employee.timeStatus,
                            isLate ? secondary : AppColors.success,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Check-out Time',
                            employee.checkOut,
                            '-',
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Department Section
                      _buildDetailCard(
                        title: 'Employee Information',
                        icon: Icons.person_outline,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            'Department',
                            employee.dept,
                            '',
                            Colors.transparent,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Status Label',
                            employee.statusLabel,
                            '',
                            Colors.transparent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Contact Information
                      _buildDetailCard(
                        title: 'Contact Information',
                        icon: Icons.contact_mail_outlined,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            'Email',
                            employee.email ?? 'N/A',
                            '',
                            Colors.transparent,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Phone Number',
                            employee.phone ?? 'N/A',
                            '',
                            Colors.transparent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Organization Details
                      _buildDetailCard(
                        title: 'Organization Details',
                        icon: Icons.business_outlined,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            'Office ID',
                            employee.officeId ?? 'N/A',
                            '',
                            Colors.transparent,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Department ID',
                            employee.departmentId ?? 'N/A',
                            '',
                            Colors.transparent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${employee.name} details saved to clipboard',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.file_download),
                              label: const Text('Export'),
                            ),
                          ),
                        ],
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
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color primary,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    String suffix,
    Color suffixColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (suffix.isNotEmpty)
          Text(
            suffix,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: suffixColor,
            ),
          ),
      ],
    );
  }
}
