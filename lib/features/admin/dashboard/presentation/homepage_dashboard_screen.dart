import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/map_styles.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';
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
            final isTablet = constraints.maxWidth >= 800;
            final isCompact = !isDesktop;

            final mainContent = Column(
              children: [
                AdminHeaderBar(_scaffoldKey),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isCompact ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(isCompact),
                        SizedBox(height: isCompact ? 20 : 32),

                        // Adaptive Layout for Tables/Map
                        if (isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildAttendanceTable()),
                              SizedBox(width: isCompact ? 16 : 32),
                              Expanded(flex: 1, child: _buildRightPanel()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildAttendanceTable(),
                              const SizedBox(height: 24),
                              _buildRightPanel(),
                            ],
                          ),
                      ],
                    ),
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
                      color: AppColors.success, // Ensure this class exists
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
                          value: animatedValue, // Use the animated value
                          strokeWidth: 3,
                          backgroundColor: color.withOpacity(0.1),
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                    // END CHANGE
                  ),
                ],
              ],
            ),
            if (progress != null || isAlert)
              Text(
                sub,
                style: TextStyle(
                  color: isAlert
                      ? AppColors
                            .error // Ensure this class exists
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

    if (!isCompact) {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: c,
                ),
              ),
            )
            .toList(),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0);
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards
          .map(
            (c) => SizedBox(
              width:
                  (MediaQuery.of(context).size.width - 64) /
                  (MediaQuery.of(context).size.width < 600 ? 1 : 2),
              child: c,
            ),
          )
          .toList(),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // --- 4. Attendance Table ---
  Widget _buildAttendanceTable() {
    final rows = buildAttendanceRows(limit: 5);

    // Header Cell Helper
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
              TextButton(
                onPressed: () {},
                child: Text(AppStrings.tr('view_all')),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          // Table Rows
          ...rows.map((row) {
            final color = row.isLate ? AppColors.secondary : AppColors.success;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icons.more_vert,
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

  // --- 5. Right Panel (Map & Top Performers) ---
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
              onPressed: () {},
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
    if (mounted) {
      Navigator.of(context).pushNamed(routeName);
      if (_scaffoldKey.currentState?.isDrawerOpen == true) {
        Navigator.pop(context);
      }
    }
  }
}
