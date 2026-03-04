import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/geofencing_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
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
                                            AppStrings.tr('loading'),
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
        if (constraints.maxWidth >= 1100) {
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
        } else if (constraints.maxWidth >= 700) {
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
        } else {
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
              prefixIconColor: Theme.of(context).colorScheme.primary,
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.6),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office.officeName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        Expanded(
                          child: Text(
                            geofence.addressLabel.isNotEmpty
                                ? geofence.addressLabel
                                : '${AppStrings.tr('latitude')}: ${geofence.lat.toStringAsFixed(4)}, ${AppStrings.tr('longitude')}: ${geofence.lng.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isEditing)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      tooltip: AppStrings.tr('edit_office'),
                      onPressed: () => _showEditOfficeDialog(context, office),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _controller.startEditing,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(AppStrings.tr('adjust_geofence')),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: AppStrings.tr('delete'),
                      onPressed: () => _showDeleteConfirmation(context, office),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    TextButton(
                      onPressed: _controller.cancelEdit,
                      child: Text(AppStrings.tr('cancel')),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        _controller.saveChanges();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            content: Text(
                              AppStrings.tr('geofence_updated_success'),
                              style: TextStyle(color: Colors.white),
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
        _buildOfficeMetaInfo(office),
        Expanded(
          child: Stack(
            children: [
              _buildInteractiveMap(
                lat: geofence.lat,
                lng: geofence.lng,
                radius: geofence.radiusMeters,
                isEditing: isEditing,
                onPositionChanged: (lat, lng) =>
                    _controller.updateTempGeofence(lat: lat, lng: lng),
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
                            onChanged: (val) => _controller.updateTempGeofence(
                              radius: val.toInt(),
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
        Future.microtask(
          () => _mainMapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          ),
        );
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
    _showOfficeFormDialog(context: context);
  }

  void _showEditOfficeDialog(BuildContext context, OfficeConfig office) {
    _showOfficeFormDialog(
      context: context,
      isEdit: true,
      officeId: office.officeId,
      initialName: office.officeName,
      initialGroup: office.groupName,
      initialCheckIn: office.policy.checkInStart,
      initialCheckOut: office.policy.checkOutEnd,
      initialAnnualLeave: office.policy.annualLeaveLimit,
      initialSickLeave: office.policy.sickLeaveLimit,
      initialBotUsername: office.telegramConfig.botUsername,
      initialBotLink: office.telegramConfig.botLink,
    );
  }

  void _showOfficeFormDialog({
    required BuildContext context,
    bool isEdit = false,
    String? officeId,
    String? initialName,
    String? initialGroup,
    String? initialCheckIn,
    String? initialCheckOut,
    int? initialAnnualLeave,
    int? initialSickLeave,
    String? initialBotUsername,
    String? initialBotLink,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: initialName);
    final groupCtrl = TextEditingController(text: initialGroup);
    final checkInCtrl = TextEditingController(
      text: initialCheckIn ?? '09:00 AM',
    );
    final checkOutCtrl = TextEditingController(
      text: initialCheckOut ?? '06:00 PM',
    );
    final annualLeaveCtrl = TextEditingController(
      text: (initialAnnualLeave ?? 20).toString(),
    );
    final sickLeaveCtrl = TextEditingController(
      text: (initialSickLeave ?? 10).toString(),
    );
    final botUsernameCtrl = TextEditingController(text: initialBotUsername);
    final botLinkCtrl = TextEditingController(text: initialBotLink);
    double? selectedLat;
    double? selectedLng;
    String selectedAddress = "";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final hasLocation =
              isEdit || (selectedLat != null && selectedLng != null);
          final hasAllRequiredData =
              nameCtrl.text.trim().isNotEmpty &&
              groupCtrl.text.trim().isNotEmpty &&
              checkInCtrl.text.trim().isNotEmpty &&
              checkOutCtrl.text.trim().isNotEmpty &&
              botUsernameCtrl.text.trim().isNotEmpty &&
              botLinkCtrl.text.trim().isNotEmpty &&
              (int.tryParse(annualLeaveCtrl.text.trim()) ?? -1) >= 0 &&
              (int.tryParse(sickLeaveCtrl.text.trim()) ?? -1) >= 0;
          final colorScheme = Theme.of(context).colorScheme;
          final modernFillColor = colorScheme.surfaceContainerHighest
              .withOpacity(0.45);
          final defaultOutlineBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.6),
            ),
          );
          final focusedOutlineBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          );
          final errorOutlineBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.error),
          );

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
                  isEdit
                      ? AppStrings.tr('edit_office')
                      : AppStrings.tr('create_new_office'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEdit
                      ? AppStrings.tr('update_office_details')
                      : AppStrings.tr('define_geofenced_area'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('office_label'),
                          hintText: AppStrings.tr('headquarters_example'),
                          prefixIcon: const Icon(Icons.business_outlined),
                          prefixIconColor: colorScheme.primary,
                          filled: true,
                          fillColor: modernFillColor,
                          border: defaultOutlineBorder,
                          enabledBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          errorBorder: errorOutlineBorder,
                          focusedErrorBorder: errorOutlineBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? AppStrings.tr('office_name_required')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: groupCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('group_department'),
                          hintText: AppStrings.tr('engineering_example'),
                          prefixIcon: const Icon(Icons.group_outlined),
                          prefixIconColor: colorScheme.primary,
                          filled: true,
                          fillColor: modernFillColor,
                          border: defaultOutlineBorder,
                          enabledBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          errorBorder: errorOutlineBorder,
                          focusedErrorBorder: errorOutlineBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? AppStrings.tr('group_name_required')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: checkInCtrl,
                        readOnly: true,
                        onTap: () => _pickTimeForController(
                          context: context,
                          controller: checkInCtrl,
                          setDialogState: setDialogState,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('policy_check_in_time'),
                          hintText: '09:00 AM',
                          prefixIcon: const Icon(Icons.login),
                          prefixIconColor: colorScheme.primary,
                          suffixIcon: const Icon(Icons.access_time),
                          filled: true,
                          fillColor: modernFillColor,
                          border: defaultOutlineBorder,
                          enabledBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          errorBorder: errorOutlineBorder,
                          focusedErrorBorder: errorOutlineBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? AppStrings.tr('check_in_time_required')
                            : _parseTimeOfDay(v) == null
                            ? AppStrings.tr('invalid_time_format')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: checkOutCtrl,
                        readOnly: true,
                        onTap: () => _pickTimeForController(
                          context: context,
                          controller: checkOutCtrl,
                          setDialogState: setDialogState,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('policy_check_out_time'),
                          hintText: '06:00 PM',
                          prefixIcon: const Icon(Icons.logout),
                          prefixIconColor: colorScheme.primary,
                          suffixIcon: const Icon(Icons.access_time),
                          filled: true,
                          fillColor: modernFillColor,
                          border: defaultOutlineBorder,
                          enabledBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          errorBorder: errorOutlineBorder,
                          focusedErrorBorder: errorOutlineBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? AppStrings.tr('check_out_time_required')
                            : _parseTimeOfDay(v) == null
                            ? AppStrings.tr('invalid_time_format')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: annualLeaveCtrl,
                              onChanged: (_) => setDialogState(() {}),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: AppStrings.tr('annual_leave_limit'),
                                prefixIcon: const Icon(
                                  Icons.beach_access_outlined,
                                ),
                                prefixIconColor: colorScheme.primary,
                                suffixIcon: SizedBox(
                                  width: 84,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: AppStrings.tr('decrease'),
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          final current =
                                              int.tryParse(
                                                annualLeaveCtrl.text,
                                              ) ??
                                              0;
                                          final next = current > 0
                                              ? current - 1
                                              : 0;
                                          setDialogState(() {
                                            annualLeaveCtrl.text = next
                                                .toString();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        tooltip: AppStrings.tr('increase'),
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          final current =
                                              int.tryParse(
                                                annualLeaveCtrl.text,
                                              ) ??
                                              0;
                                          setDialogState(() {
                                            annualLeaveCtrl.text = (current + 1)
                                                .toString();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                filled: true,
                                fillColor: modernFillColor,
                                border: defaultOutlineBorder,
                                enabledBorder: defaultOutlineBorder,
                                focusedBorder: focusedOutlineBorder,
                                errorBorder: errorOutlineBorder,
                                focusedErrorBorder: errorOutlineBorder,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                final raw = v?.trim() ?? '';
                                if (raw.isEmpty) {
                                  return AppStrings.tr('annual_leave_required');
                                }
                                final value = int.tryParse(raw);
                                if (value == null || value < 0) {
                                  return AppStrings.tr(
                                    'annual_leave_must_number',
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: sickLeaveCtrl,
                              onChanged: (_) => setDialogState(() {}),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: AppStrings.tr('sick_leave_limit'),
                                prefixIcon: const Icon(
                                  Icons.local_hospital_outlined,
                                ),
                                prefixIconColor: colorScheme.primary,
                                suffixIcon: SizedBox(
                                  width: 84,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: AppStrings.tr('decrease'),
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          final current =
                                              int.tryParse(
                                                sickLeaveCtrl.text,
                                              ) ??
                                              0;
                                          final next = current > 0
                                              ? current - 1
                                              : 0;
                                          setDialogState(() {
                                            sickLeaveCtrl.text = next
                                                .toString();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        tooltip: AppStrings.tr('increase'),
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          final current =
                                              int.tryParse(
                                                sickLeaveCtrl.text,
                                              ) ??
                                              0;
                                          setDialogState(() {
                                            sickLeaveCtrl.text = (current + 1)
                                                .toString();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                filled: true,
                                fillColor: modernFillColor,
                                border: defaultOutlineBorder,
                                enabledBorder: defaultOutlineBorder,
                                focusedBorder: focusedOutlineBorder,
                                errorBorder: errorOutlineBorder,
                                focusedErrorBorder: errorOutlineBorder,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                final raw = v?.trim() ?? '';
                                if (raw.isEmpty) {
                                  return AppStrings.tr('sick_leave_required');
                                }
                                final value = int.tryParse(raw);
                                if (value == null || value < 0) {
                                  return AppStrings.tr(
                                    'sick_leave_must_number',
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: botUsernameCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('telegram_bot_username'),
                          hintText: '@your_bot',
                          prefixIcon: const Icon(Icons.smart_toy_outlined),
                          prefixIconColor: colorScheme.primary,
                          filled: true,
                          fillColor: modernFillColor,
                          border: defaultOutlineBorder,
                          enabledBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          errorBorder: errorOutlineBorder,
                          focusedErrorBorder: errorOutlineBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? AppStrings.tr('telegram_bot_username_required')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: botLinkCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('telegram_bot_link'),
                          hintText: 'https://t.me/your_bot',
                          prefixIcon: const Icon(Icons.link_outlined),
                          prefixIconColor: colorScheme.primary,
                          filled: true,
                          fillColor: modernFillColor,
                          border: defaultOutlineBorder,
                          enabledBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          errorBorder: errorOutlineBorder,
                          focusedErrorBorder: errorOutlineBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? AppStrings.tr('telegram_bot_link_required')
                            : null,
                      ),
                      if (!isEdit) ...[
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: hasAllRequiredData
                              ? () async {
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
                                }
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: hasLocation
                                  ? colorScheme.primaryContainer.withOpacity(
                                      0.4,
                                    )
                                  : hasAllRequiredData
                                  ? colorScheme.surfaceContainerHighest
                                        .withOpacity(0.3)
                                  : colorScheme.errorContainer.withOpacity(
                                      0.35,
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: hasLocation
                                    ? colorScheme.primary.withOpacity(0.5)
                                    : hasAllRequiredData
                                    ? Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.5)
                                    : colorScheme.error.withOpacity(0.8),
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
                                        : hasAllRequiredData
                                        ? colorScheme.surfaceContainerHighest
                                        : colorScheme.error.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    hasLocation
                                        ? Icons.location_on
                                        : Icons.map_outlined,
                                    color: hasLocation
                                        ? colorScheme.onPrimary
                                        : hasAllRequiredData
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.error,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hasLocation
                                            ? AppStrings.tr('location_selected')
                                            : AppStrings.tr(
                                                'set_office_location',
                                              ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color:
                                              !hasAllRequiredData &&
                                                  !hasLocation
                                              ? colorScheme.error
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        hasLocation
                                            ? (selectedAddress.isEmpty
                                                  ? '${AppStrings.tr('latitude')}: ${selectedLat!.toStringAsFixed(4)}, ${AppStrings.tr('longitude')}: ${selectedLng!.toStringAsFixed(4)}'
                                                  : selectedAddress)
                                            : hasAllRequiredData
                                            ? AppStrings.tr('tap_open_map')
                                            : AppStrings.tr(
                                                'complete_required_fields_first',
                                              ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  !hasAllRequiredData &&
                                                      !hasLocation
                                                  ? colorScheme.error
                                                  : colorScheme
                                                        .onSurfaceVariant,
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
                                      : hasAllRequiredData
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.error,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.tr('cancel')),
              ),
              FilledButton(
                onPressed:
                    hasLocation && formKey.currentState?.validate() == true
                    ? () async {
                        if (isEdit) {
                          await _controller.updateOfficeDetails(
                            officeId: officeId!,
                            newName: nameCtrl.text,
                            newGroup: groupCtrl.text,
                            checkInStart: checkInCtrl.text.trim(),
                            checkOutEnd: checkOutCtrl.text.trim(),
                            annualLeaveLimit: int.parse(
                              annualLeaveCtrl.text.trim(),
                            ),
                            sickLeaveLimit: int.parse(
                              sickLeaveCtrl.text.trim(),
                            ),
                            botUsername: botUsernameCtrl.text.trim(),
                            botLink: botLinkCtrl.text.trim(),
                          );
                        } else {
                          final fallbackAddress =
                              '${AppStrings.tr('latitude')}: ${selectedLat!.toStringAsFixed(4)}, ${AppStrings.tr('longitude')}: ${selectedLng!.toStringAsFixed(4)}';
                          await _controller.addNewOffice(
                            officeName: nameCtrl.text,
                            groupName: groupCtrl.text,
                            lat: selectedLat!,
                            lng: selectedLng!,
                            radiusMeters: 200,
                            addressLabel: selectedAddress.isNotEmpty
                                ? selectedAddress
                                : fallbackAddress,
                            checkInStart: checkInCtrl.text.trim(),
                            checkOutEnd: checkOutCtrl.text.trim(),
                            annualLeaveLimit: int.parse(
                              annualLeaveCtrl.text.trim(),
                            ),
                            sickLeaveLimit: int.parse(
                              sickLeaveCtrl.text.trim(),
                            ),
                            botUsername: botUsernameCtrl.text.trim(),
                            botLink: botLinkCtrl.text.trim(),
                          );
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            content: Text(
                              isEdit
                                  ? AppStrings.tr('office_updated_success')
                                  : AppStrings.tr('office_created_success'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  isEdit
                      ? AppStrings.tr('save_changes')
                      : AppStrings.tr('create_office'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic office) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr('delete_office')),
        content: Text(
          '${AppStrings.tr('confirm_delete_msg')} ${office.officeName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await _controller.deleteOffice(office.officeId);
              if (!context.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  content: Text(
                    AppStrings.tr('office_deleted_success'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            child: Text(AppStrings.tr('delete')),
          ),
        ],
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

  Future<void> _pickTimeForController({
    required BuildContext context,
    required TextEditingController controller,
    required void Function(void Function()) setDialogState,
  }) async {
    final initial =
        _parseTimeOfDay(controller.text) ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Theme(
          data: theme.copyWith(
            timePickerTheme: theme.timePickerTheme.copyWith(
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.primary;
                }
                return colorScheme.surfaceContainerHighest;
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                return colorScheme.onSurface;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.primary;
                }
                return colorScheme.surfaceContainerHighest;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                return colorScheme.onSurface;
              }),
              dialHandColor: colorScheme.primary,
              dialBackgroundColor: colorScheme.surfaceContainerHighest,
              entryModeIconColor: colorScheme.primary,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );

    if (picked == null) return;
    setDialogState(() {
      controller.text = _formatTimeOfDay12Hour(picked);
    });
  }

  String _formatTimeOfDay12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null) return null;
    final text = value.trim();
    if (text.isEmpty) return null;

    final twelveHour = RegExp(
      r'^(0?[1-9]|1[0-2]):([0-5][0-9])\s*([AaPp][Mm])$',
    );
    final twelveMatch = twelveHour.firstMatch(text);
    if (twelveMatch != null) {
      final hour = int.parse(twelveMatch.group(1)!);
      final minute = int.parse(twelveMatch.group(2)!);
      final period = twelveMatch.group(3)!.toUpperCase();
      final normalizedHour = period == 'PM'
          ? (hour == 12 ? 12 : hour + 12)
          : (hour == 12 ? 0 : hour);
      return TimeOfDay(hour: normalizedHour, minute: minute);
    }

    final twentyFourHour = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    final twentyFourMatch = twentyFourHour.firstMatch(text);
    if (twentyFourMatch != null) {
      final hour = int.parse(twentyFourMatch.group(1)!);
      final minute = int.parse(twentyFourMatch.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    }

    return null;
  }

  Widget _buildOfficeMetaInfo(OfficeConfig office) {
    final policy = office.policy;
    final telegram = office.telegramConfig;

    Widget infoChip(IconData icon, String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(text, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              infoChip(
                Icons.login,
                '${AppStrings.tr('check_in_label')} ${policy.checkInStart}',
              ),
              infoChip(
                Icons.logout,
                '${AppStrings.tr('check_out_label')} ${policy.checkOutEnd}',
              ),
              infoChip(
                Icons.beach_access_outlined,
                '${AppStrings.tr('annual_label')} ${policy.annualLeaveLimit}',
              ),
              infoChip(
                Icons.local_hospital_outlined,
                '${AppStrings.tr('sick_label')} ${policy.sickLeaveLimit}',
              ),
              infoChip(
                Icons.smart_toy_outlined,
                telegram.botUsername.isNotEmpty
                    ? telegram.botUsername
                    : AppStrings.tr('no_telegram_username'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: telegram.botLink.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(
                      ClipboardData(text: telegram.botLink),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.tr('bot_link_copied'),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      telegram.botLink.isNotEmpty
                          ? telegram.botLink
                          : AppStrings.tr('no_telegram_link'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
