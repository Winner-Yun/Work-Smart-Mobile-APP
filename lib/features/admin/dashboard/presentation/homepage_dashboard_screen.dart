import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
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
  String _sortBy = 'name';
  int _attendancePage = 0;
  String? _selectedOfficeId;

  // Map Specifics
  gmaps.GoogleMapController? _mapController;
  gmaps.BitmapDescriptor? _officeMarkerIcon;
  String _lastMapViewportSignature = '';

  // Hover State
  final bool _isProfileHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    initializeDashboardRealtimeData();
    _loadOfficeMarkerIcon();
  }

  Future<void> _loadOfficeMarkerIcon() async {
    try {
      final ByteData data = await rootBundle.load(AppImg.pinIcon);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 40,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final bytes = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (bytes == null || !mounted) return;

      setState(() {
        _officeMarkerIcon = gmaps.BitmapDescriptor.fromBytes(
          bytes.buffer.asUint8List(),
        );
      });
    } catch (e) {
      debugPrint('Error loading office pin icon: $e');
    }
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

  void _fitMapToOffices(List<OfficeConfig> offices) {
    final controller = _mapController;
    if (controller == null || offices.isEmpty) return;

    if (offices.length == 1) {
      final office = offices.first;
      controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(office.geofence.lat, office.geofence.lng),
            zoom: 15.5,
          ),
        ),
      );
      return;
    }

    double minLat = offices.first.geofence.lat;
    double maxLat = offices.first.geofence.lat;
    double minLng = offices.first.geofence.lng;
    double maxLng = offices.first.geofence.lng;

    for (final office in offices.skip(1)) {
      minLat = math.min(minLat, office.geofence.lat);
      maxLat = math.max(maxLat, office.geofence.lat);
      minLng = math.min(minLng, office.geofence.lng);
      maxLng = math.max(maxLng, office.geofence.lng);
    }

    final hasSinglePoint =
        (maxLat - minLat).abs() < 0.0001 && (maxLng - minLng).abs() < 0.0001;
    if (hasSinglePoint) {
      controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(minLat, minLng),
            zoom: 14.5,
          ),
        ),
      );
      return;
    }

    controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(minLat, minLng),
          northeast: gmaps.LatLng(maxLat, maxLng),
        ),
        64,
      ),
    );
  }

  void _scheduleMapViewportUpdate(List<OfficeConfig> offices) {
    final signature = offices
        .map(
          (office) =>
              '${office.officeId}:${office.geofence.lat.toStringAsFixed(5)}:${office.geofence.lng.toStringAsFixed(5)}:${office.geofence.radiusMeters}',
        )
        .join('|');

    if (_lastMapViewportSignature == signature) return;
    _lastMapViewportSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToOffices(offices);
    });
  }

  OfficeConfig? _resolveSelectedOffice(List<OfficeConfig> offices) {
    if (offices.isEmpty) return null;

    final selectedId = _selectedOfficeId?.trim();
    if (selectedId == null || selectedId.isEmpty) {
      return offices.first;
    }

    final matched = offices.where((office) => office.officeId == selectedId);
    if (matched.isNotEmpty) {
      return matched.first;
    }

    return offices.first;
  }

  String _officeDisplayName(OfficeConfig office) {
    final trimmedName = office.officeName.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }
    return office.officeId;
  }

  @override
  void dispose() {
    disposeDashboardRealtimeData();
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
        dashboardDataVersion,
      ]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
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
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                            0.5,
                                        child: _buildGeofenceCard(),
                                      ),
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
        ? allRows
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
    const pageSize = 5;
    const rowHeight = 74.0;
    const paginationBarHeight = 44.0;
    final totalPages = filteredRows.isEmpty
        ? 1
        : ((filteredRows.length + pageSize - 1) ~/ pageSize);
    final currentPage = _attendancePage.clamp(0, totalPages - 1);
    final startIndex = currentPage * pageSize;
    final endIndex = math.min(startIndex + pageSize, filteredRows.length);
    final pagedRows = filteredRows.isEmpty
        ? <AttendanceRowData>[]
        : filteredRows.sublist(startIndex, endIndex);
    final emptySlots = pageSize - pagedRows.length;
    final showingFrom = filteredRows.isEmpty ? 0 : startIndex + 1;
    final showingTo = filteredRows.isEmpty ? 0 : endIndex;

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
          else ...[
            SizedBox(
              height: pageSize * rowHeight,
              child: Column(
                children: [
                  ...pagedRows.map((row) {
                    final color = row.isLate
                        ? AppColors.secondary
                        : AppColors.success;

                    return SizedBox(
                      height: rowHeight,
                      child: Padding(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            _buildProfileAvatar(
                                              name: row.name,
                                              imageUrl: row.profileUrl,
                                            ),
                                            SizedBox(width: 12),
                                            Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    row.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 6,
                                                color: color,
                                              ),
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
                      ),
                    );
                  }),
                  ...List.generate(
                    emptySlots,
                    (_) => SizedBox(
                      height: rowHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: paginationBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _trFormat('attendance_showing_range', {
                      'from': '$showingFrom',
                      'to': '$showingTo',
                      'total': '${filteredRows.length}',
                    }),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _trFormat('attendance_page_fraction', {
                      'current': '${currentPage + 1}',
                      'total': '$totalPages',
                    }),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: currentPage > 0
                        ? () {
                            setState(() {
                              _attendancePage = currentPage - 1;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: AppStrings.tr('previous_page'),
                  ),
                  IconButton(
                    onPressed: currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              _attendancePage = currentPage + 1;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: AppStrings.tr('next_page'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _trFormat(String key, Map<String, String> values) {
    var text = AppStrings.tr(key);
    values.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

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
    final offices = getAllOfficeConfigs();
    final hasOffices = offices.isNotEmpty;
    final selectedOffice = _resolveSelectedOffice(offices);
    final displayedOffices = selectedOffice == null
        ? offices
        : <OfficeConfig>[selectedOffice];

    _scheduleMapViewportUpdate(displayedOffices);

    final initialTarget = selectedOffice != null
        ? gmaps.LatLng(selectedOffice.geofence.lat, selectedOffice.geofence.lng)
        : hasOffices
        ? gmaps.LatLng(offices.first.geofence.lat, offices.first.geofence.lng)
        : const gmaps.LatLng(11.5564, 104.9282);

    final markers = displayedOffices
        .map(
          (office) => gmaps.Marker(
            markerId: gmaps.MarkerId('office_${office.officeId}'),
            position: gmaps.LatLng(office.geofence.lat, office.geofence.lng),
            icon: _officeMarkerIcon ?? gmaps.BitmapDescriptor.defaultMarker,
            anchor: const Offset(0.5, 0.5),
            infoWindow: gmaps.InfoWindow(
              title: office.officeName,
              snippet: office.geofence.addressLabel,
            ),
          ),
        )
        .toSet();

    final circles = displayedOffices
        .map(
          (office) => gmaps.Circle(
            circleId: gmaps.CircleId('radius_${office.officeId}'),
            center: gmaps.LatLng(office.geofence.lat, office.geofence.lng),
            radius: office.geofence.radiusMeters.toDouble(),
            strokeWidth: 2,
            strokeColor: primary.withOpacity(0.9),
            fillColor: primary.withOpacity(0.16),
          ),
        )
        .toSet();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.map_outlined, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    selectedOffice == null
                        ? AppStrings.tr('total_locations')
                        : _officeDisplayName(selectedOffice),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      selectedOffice == null
                          ? '${offices.length}'
                          : '1 / ${offices.length}',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: AppStrings.tr('geofencing_management'),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                      icon: Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: primary,
                      ),
                      onPressed: () => _navigateTo(AppAdminRoute.geofencing),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasOffices)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.4),
                ),
              ),
              child: DropdownButton<String>(
                value: selectedOffice?.officeId,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (officeId) {
                  if (officeId == null) return;
                  setState(() {
                    _selectedOfficeId = officeId;
                  });
                },
                items: offices
                    .map(
                      (office) => DropdownMenuItem<String>(
                        value: office.officeId,
                        child: Text(
                          _officeDisplayName(office),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (hasOffices) const SizedBox(height: 16),
          _buildInfoRow(
            Icons.domain_outlined,
            AppStrings.tr('total_locations'),
            '${offices.length}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_city,
            AppStrings.tr('office_address'),
            selectedOffice == null ? '-' : selectedOffice.geofence.addressLabel,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.radar,
            AppStrings.tr('geofence_radius'),
            selectedOffice == null
                ? '-'
                : '${selectedOffice.geofence.radiusMeters}m',
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
                  target: initialTarget,
                  zoom: hasOffices ? 13.0 : 3.0,
                ),
                onMapCreated: (c) {
                  _mapController = c;
                  _applyMapStyle();
                  _fitMapToOffices(displayedOffices);
                },
                markers: markers,
                circles: circles,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          if (!hasOffices)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'No office locations available.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final performers = buildTopPerformers(limit: 3);
    final TopPerformerData? first = performers.isNotEmpty
        ? performers[0]
        : null;
    final TopPerformerData? second = performers.length > 1
        ? performers[1]
        : null;
    final TopPerformerData? third = performers.length > 2
        ? performers[2]
        : null;

    final podiumOrder = <TopPerformerData?>[second, first, third];
    final podiumGradients = <List<Color>>[
      const <Color>[Color(0xFFE5E7EB), Color(0xFFF3F4F6)],
      const <Color>[Color(0xFFF5E58B), Color(0xFFF3EFCF)],
      const <Color>[Color(0xFFE8D1BC), Color(0xFFF3E7DB)],
    ];
    final podiumRingColors = <Color>[
      const Color(0xFFB7BCC6),
      const Color(0xFFF2C500),
      const Color(0xFFC87A2A),
    ];
    final podiumScoreColors = <Color>[
      const Color(0xFFA8ADB5),
      const Color(0xFFF2C500),
      const Color(0xFFC87A2A),
    ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;
              final sideHeight = isNarrow ? 160.0 : 188.0;
              final centerHeight = isNarrow ? 200.0 : 232.0;
              final sideAvatarRadius = isNarrow ? 22.0 : 28.0;
              final centerAvatarRadius = isNarrow ? 27.0 : 34.0;
              final podiumHeights = <double>[
                sideHeight,
                centerHeight,
                sideHeight,
              ];
              final podiumAvatarRadii = <double>[
                sideAvatarRadius,
                centerAvatarRadius,
                sideAvatarRadius,
              ];

              return SizedBox(
                height: centerHeight + 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 6,
                          right: index == 2 ? 0 : 6,
                        ),
                        child: _buildTopPerformerPodiumCard(
                          performer: podiumOrder[index],
                          height: podiumHeights[index],
                          avatarRadius: podiumAvatarRadii[index],
                          gradientColors: podiumGradients[index],
                          ringColor: podiumRingColors[index],
                          scoreColor: podiumScoreColors[index],
                          isChampion: index == 1,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0),
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

  Widget _buildTopPerformerPodiumCard({
    required TopPerformerData? performer,
    required double height,
    required double avatarRadius,
    required List<Color> gradientColors,
    required Color ringColor,
    required Color scoreColor,
    required bool isChampion,
  }) {
    final hasPerformer = performer != null;
    final performerName = hasPerformer ? performer.name : '--';
    final performerImage = hasPerformer ? performer.profileUrl : '';
    final performerScore = hasPerformer
        ? _formatPodiumScore(performer.score)
        : '--';

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isChampion ? 0.11 : 0.07),
            blurRadius: isChampion ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 3),
            ),
            child: _buildProfileAvatar(
              name: performerName,
              imageUrl: performerImage,
              radius: avatarRadius,
            ),
          ),
          SizedBox(height: isChampion ? 14 : 12),
          Text(
            performerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isChampion ? 20 : 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF252A33),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            performerScore,
            style: TextStyle(
              fontSize: isChampion ? 20 : 15,
              fontWeight: FontWeight.w900,
              color: scoreColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.tr('points_label'),
            style: TextStyle(
              fontSize: isChampion ? 9 : 8,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF252A33).withOpacity(0.65),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPodiumScore(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '--';

    final normalized = value.replaceAll('%', '').trim();
    if (normalized.isEmpty) return '--';

    final asNumber = num.tryParse(normalized);
    if (asNumber == null) {
      return normalized;
    }

    if (asNumber % 1 == 0) {
      return '${asNumber.toInt()}';
    }

    return asNumber.toStringAsFixed(1);
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
            _attendancePage = 0;
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
                          _attendancePage = 0;
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
            _attendancePage = 0;
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
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.08),
                        primary.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      _buildProfileAvatar(
                        name: employee.name,
                        imageUrl: employee.profileUrl,
                        radius: 32,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.dept,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (isLate ? secondary : AppColors.success)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isLate ? secondary : AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              employee.statusLabel,
                              style: TextStyle(
                                color: isLate ? secondary : AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.login_rounded,
                                    size: 20,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.tr('check_in_time'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        employee.checkIn,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isLate ? secondary : AppColors.success)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    employee.timeStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isLate
                                          ? secondary
                                          : AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.1),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.logout_rounded,
                                    size: 20,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.tr('check_out_time'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        employee.checkOut,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
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
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 20),
                              label: Text(AppStrings.tr('close')),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEmployeeDetails(employee);
                              },
                              icon: const Icon(Icons.info_outline, size: 20),
                              label: Text(AppStrings.tr('details_button')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.08),
                        primary.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      _buildProfileAvatar(
                        name: employee.name,
                        imageUrl: employee.profileUrl,
                        radius: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.dept,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isLate ? secondary : AppColors.success)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
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
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      _buildDetailCard(
                        title: AppStrings.tr('attendance_details'),
                        icon: Icons.schedule,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            AppStrings.tr('check_in_time'),
                            employee.checkIn,
                            employee.timeStatus,
                            isLate ? secondary : AppColors.success,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildDetailRow(
                            AppStrings.tr('check_out_time'),
                            employee.checkOut,
                            '-',
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailCard(
                        title: AppStrings.tr('employee_information'),
                        icon: Icons.person_outline,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            AppStrings.tr('department_label'),
                            employee.dept,
                            '',
                            Colors.transparent,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildDetailRow(
                            AppStrings.tr('status_label'),
                            employee.statusLabel,
                            '',
                            Colors.transparent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailCard(
                        title: AppStrings.tr('contact_information'),
                        icon: Icons.contact_mail_outlined,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            AppStrings.tr('email_label'),
                            employee.email ?? AppStrings.tr('not_available'),
                            '',
                            Colors.transparent,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildDetailRow(
                            AppStrings.tr('phone_label'),
                            employee.phone ?? AppStrings.tr('not_available'),
                            '',
                            Colors.transparent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailCard(
                        title: AppStrings.tr('organization_details'),
                        icon: Icons.business_outlined,
                        primary: primary,
                        children: [
                          _buildDetailRow(
                            AppStrings.tr('office_id_label'),
                            employee.officeId ?? AppStrings.tr('not_available'),
                            '',
                            Colors.transparent,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildDetailRow(
                            AppStrings.tr('department_id_label'),
                            employee.departmentId ??
                                AppStrings.tr('not_available'),
                            '',
                            Colors.transparent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 20),
                              label: Text(AppStrings.tr('close')),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    content: Text(
                                      _trFormat('employee_details_saved', {
                                        'name': employee.name,
                                      }),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.file_download, size: 20),
                              label: Text(AppStrings.tr('export_button')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
