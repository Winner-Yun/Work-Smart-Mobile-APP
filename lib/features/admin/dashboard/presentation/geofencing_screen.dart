import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/geofencing_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/map_picker_dailog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofencingScreen extends StatefulWidget {
  const GeofencingScreen({super.key});

  @override
  State<GeofencingScreen> createState() => _GeofencingScreenState();
}

class _GeofencingScreenState extends State<GeofencingScreen> {
  late final GeofencingController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Map state for the detail panel
  GoogleMapController? _mainMapController;
  double? _lastLat;
  double? _lastLng;

  @override
  void initState() {
    super.initState();
    _controller = GeofencingController();
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              drawer: !isDesktop ? _buildDrawer() : null,
              body: Row(
                children: [
                  if (isDesktop) _buildDesktopSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        AdminHeaderBar(_scaffoldKey, isCompact: !isDesktop),
                        Expanded(
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(isDesktop ? 32 : 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(),
                                    const SizedBox(height: 24),
                                    _buildStatsRow(),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: _buildMasterDetailLayout(
                                        isDesktop,
                                      ).animate().fade().slideY(begin: 0.2),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
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

  Widget _buildDrawer() => Drawer(child: _buildSidebarContent(true));
  Widget _buildDesktopSidebar() => _buildSidebarContent(false);

  Widget _buildSidebarContent(bool isCompact) {
    return AdminSideBar(
      isCompact: isCompact,
      geofencingSelected: true,
      onDashboardTap: () => _navigateTo(AppAdminRoute.adminDashboard),
      onStaffTap: () => _navigateTo(AppAdminRoute.staffManagement),
      onGeofencingTap: () => _navigateTo(AppAdminRoute.geofencing),
      onLeaderboardTap: () => _navigateTo(AppAdminRoute.performanceLeaderboard),
      onLeaveRequestsTap: () => _navigateTo(AppAdminRoute.leaveRequests),
      onAnalyticsTap: () => _navigateTo(AppAdminRoute.analyticsReports),
      onSettingsTap: () => _navigateTo(AppAdminRoute.systemSettings),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tr('geofencing_management'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.tr('geofencing_subtitle'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ElevatedButton.icon(
            onPressed: () => _showAddOfficeDialog(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(AppStrings.tr('new_office')),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = _controller.getGeofenceStats();

    final statCards = [
      _buildStatCard(
        AppStrings.tr('total_locations'),
        "${stats['totalOffices']}",
        Icons.domain,
        Colors.blue,
      ).animate().fade().slideY(begin: 0.2),
      _buildStatCard(
        AppStrings.tr('avg_radius'),
        "${stats['avgRadius']}${AppStrings.tr('meter_unit')}",
        Icons.radar,
        Colors.orange,
      ).animate().fade().slideY(begin: 0.2),
      _buildStatCard(
        AppStrings.tr('max_range'),
        "${stats['maxRadius']}${AppStrings.tr('meter_unit')}",
        Icons.expand,
        Colors.green,
      ).animate().fade().slideY(begin: 0.2),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;
        final isTablet = constraints.maxWidth >= 700;

        // Desktop
        if (isDesktop) {
          return Row(
            children: statCards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        }
        // Tablet
        else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 16),
                      child: statCards[0],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 16),
                      child: statCards[1],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: statCards[2],
              ),
            ],
          );
        }
        // Mobile
        else {
          return Column(
            children: statCards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: card,
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterDetailLayout(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: isDesktop ? 350 : 280, child: _buildOfficeList()),
          VerticalDivider(
            width: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
          Expanded(
            child: _controller.selectedOffice == null
                ? Center(
                    child: Text(AppStrings.tr('select_office_view_details')),
                  )
                : _buildOfficeDetailPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeList() {
    final offices = _controller.getFilteredOffices();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _controller.searchOffices(v)),
            decoration: InputDecoration(
              hintText: AppStrings.tr('search_offices'),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
          ),
        ),
        Expanded(
          child: offices.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.tr('no_data'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No offices available'
                              : 'No offices match your search',
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
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: offices.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final office = offices[index];
                    final isSelected =
                        office.officeId == _controller.selectedOfficeId;

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      onTap: () => _controller.selectOffice(office.officeId),
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.business,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                      title: Text(
                        office.officeName,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        office.groupName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOfficeDetailPanel() {
    final office = _controller.selectedOffice!;
    final geofence = _controller.currentGeofence!;
    final isEditing = _controller.isEditing;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    office.officeName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        geofence.addressLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              if (!isEditing)
                OutlinedButton.icon(
                  onPressed: _controller.startEditing,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(AppStrings.tr('adjust_geofence')),
                )
              else
                Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton(
                        onPressed: _controller.cancelEdit,
                        child: Text(AppStrings.tr('cancel')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        _controller.saveChanges();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.tr('geofence_updated_success'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(AppStrings.tr('save_changes')),
                    ),
                  ],
                ),
            ],
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              _buildInteractiveMap(
                lat: geofence.lat,
                lng: geofence.lng,
                radius: geofence.radiusMeters,
                isEditing: isEditing,
                onPositionChanged: (lat, lng) {
                  _controller.updateTempGeofence(lat: lat, lng: lng);
                },
              ),

              if (isEditing)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.tr('geofence_radius'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${geofence.radiusMeters} ${AppStrings.tr('meter_unit')}",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: geofence.radiusMeters.toDouble(),
                            min: 50,
                            max: 2000,
                            divisions: 39,
                            label:
                                "${geofence.radiusMeters}${AppStrings.tr('meter_unit')}",
                            onChanged: (val) {
                              _controller.updateTempGeofence(
                                radius: val.toInt(),
                              );
                            },
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
  }

  Widget _buildInteractiveMap({
    required double lat,
    required double lng,
    required int radius,
    required bool isEditing,
    Function(double, double)? onPositionChanged,
  }) {
    if (_lastLat != lat || _lastLng != lng) {
      _lastLat = lat;
      _lastLng = lng;
      if (_mainMapController != null) {
        Future.microtask(() {
          _mainMapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          );
        });
      }
    }

    final center = LatLng(lat, lng);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 16),
      onMapCreated: (c) => _mainMapController = c,
      onTap: isEditing
          ? (pos) => onPositionChanged?.call(pos.latitude, pos.longitude)
          : null,
      markers: {
        Marker(
          markerId: const MarkerId('center'),
          position: center,
          draggable: isEditing,
          onDragEnd: (pos) =>
              onPositionChanged?.call(pos.latitude, pos.longitude),
        ),
      },
      circles: {
        Circle(
          circleId: const CircleId('fence'),
          center: center,
          radius: radius.toDouble(),
          strokeWidth: 2,
          strokeColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        ),
      },
      zoomControlsEnabled: true,
      myLocationButtonEnabled: false,
    );
  }

  void _showAddOfficeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final groupCtrl = TextEditingController();
    double? selectedLat;
    double? selectedLng;
    String selectedAddress = "";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final hasLocation = selectedLat != null && selectedLng != null;
          final colorScheme = Theme.of(context).colorScheme;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.tr('create_new_office'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.tr('define_geofenced_area'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: AppStrings.tr('office_label'),
                        hintText: AppStrings.tr('headquarters_example'),
                        prefixIcon: const Icon(Icons.business_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? AppStrings.tr('office_name_required')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: groupCtrl,
                      decoration: InputDecoration(
                        labelText: AppStrings.tr('group_department'),
                        hintText: AppStrings.tr('engineering_example'),
                        prefixIcon: const Icon(Icons.group_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? AppStrings.tr('group_name_required')
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Improved Location Picker Card
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () async {
                          final result = await _showMapPicker(
                            context,
                            selectedLat,
                            selectedLng,
                            selectedAddress,
                          );
                          if (result != null) {
                            setDialogState(() {
                              selectedLat = result['lat'];
                              selectedLng = result['lng'];
                              selectedAddress = result['address'] ?? '';
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: hasLocation
                                ? colorScheme.primaryContainer.withOpacity(0.4)
                                : colorScheme.surfaceContainerHighest
                                      .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: hasLocation
                                  ? colorScheme.primary.withOpacity(0.5)
                                  : Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: hasLocation
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  hasLocation
                                      ? Icons.location_on
                                      : Icons.map_outlined,
                                  color: hasLocation
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasLocation
                                          ? AppStrings.tr('location_selected')
                                          : AppStrings.tr(
                                              'set_office_location',
                                            ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasLocation
                                          ? (selectedAddress.isEmpty
                                                ? '${AppStrings.tr('latitude')}: ${selectedLat!.toStringAsFixed(4)}, ${AppStrings.tr('longitude')}: ${selectedLng!.toStringAsFixed(4)}'
                                                : selectedAddress)
                                          : AppStrings.tr('tap_open_map'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                hasLocation
                                    ? Icons.edit_location_alt_outlined
                                    : Icons.chevron_right_rounded,
                                color: hasLocation
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
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
            actions: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppStrings.tr('cancel')),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: FilledButton(
                  onPressed:
                      hasLocation && formKey.currentState?.validate() == true
                      ? () {
                          _controller.addNewOffice(
                            officeName: nameCtrl.text,
                            groupName: groupCtrl.text,
                            lat: selectedLat!,
                            lng: selectedLng!,
                            radiusMeters: 200,
                            addressLabel: selectedAddress,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                AppStrings.tr('office_created_success'),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppStrings.tr('create_office')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _showMapPicker(
    BuildContext context,
    double? initialLat,
    double? initialLng,
    String initialAddress,
  ) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MapPickerDialog(
        initialLat: initialLat ?? 11.5564,
        initialLng: initialLng ?? 104.9282,
        initialAddress: initialAddress,
      ),
    );
  }
}
