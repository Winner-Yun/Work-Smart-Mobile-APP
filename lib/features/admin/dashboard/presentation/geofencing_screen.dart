import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/map_styles.dart';
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
  final Map<String, String> _selectedDepartmentByOfficeId = <String, String>{};
  final TextEditingController _departmentInlineEditController =
      TextEditingController();
  final FocusNode _departmentInlineEditFocusNode = FocusNode();
  String? _editingDepartmentOfficeId;

  GoogleMapController? _mainMapController;
  double? _lastLat;
  double? _lastLng;

  @override
  void initState() {
    super.initState();
    _controller = GeofencingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMainMapStyle();
  }

  void _applyMainMapStyle() {
    if (_mainMapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _mainMapController!.setMapStyle(isDark ? MapStyles.dark : null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _departmentInlineEditController.dispose();
    _departmentInlineEditFocusNode.dispose();
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
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              office.officeName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        office.geofence.addressLabel.isNotEmpty
                            ? office.geofence.addressLabel
                            : '${AppStrings.tr('latitude')}: ${office.geofence.lat.toStringAsFixed(4)}, ${AppStrings.tr('longitude')}: ${office.geofence.lng.toStringAsFixed(4)}',
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
    final departments = _officeDepartments(office);
    final selectedDepartmentForHeader = _selectedDepartmentForOffice(office);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      office.officeName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isEditing && selectedDepartmentForHeader != null)
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: _buildDepartmentDropdownActions(
                          office: office,
                          departments: departments,
                          selectedDepartment: selectedDepartmentForHeader,
                        ),
                      ),
                    )
                  else
                    const Spacer(flex: 3),
                  const SizedBox(width: 12),
                  if (!isEditing)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note),
                          tooltip: AppStrings.tr('edit_office'),
                          onPressed: () =>
                              _showEditOfficeDialog(context, office),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: AppStrings.tr('delete_office'),
                          onPressed: () =>
                              _showDeleteConfirmation(context, office),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _controller.startEditing,
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: Text(AppStrings.tr('adjust_geofence')),
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
              const SizedBox(height: 8),
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
      onMapCreated: (c) {
        _mainMapController = c;
        _applyMainMapStyle();
      },
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

  String? _validateOfficeName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) {
      return AppStrings.tr('office_name_required');
    }

    final compactLength = name.replaceAll(RegExp(r'\s+'), '').length;
    if (compactLength < 5) {
      return AppStrings.tr('office_name_min_length');
    }

    return null;
  }

  List<String> _officeDepartments(OfficeConfig office) {
    final departments = <String>{
      ...office.departments.map((value) => value.trim()),
      office.groupName.trim(),
    }.where((value) => value.isNotEmpty).toList();

    departments.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return departments;
  }

  String? _selectedDepartmentForOffice(OfficeConfig office) {
    final departments = _officeDepartments(office);
    if (departments.isEmpty) {
      return null;
    }

    final selected = _selectedDepartmentByOfficeId[office.officeId];
    if (selected != null && departments.contains(selected)) {
      return selected;
    }

    final fallback = departments.first;
    _selectedDepartmentByOfficeId[office.officeId] = fallback;
    return fallback;
  }

  void _startInlineDepartmentEdit(OfficeConfig office, String departmentName) {
    final normalizedDepartmentName = departmentName.trim();
    setState(() {
      _editingDepartmentOfficeId = office.officeId;
      _departmentInlineEditController.text = normalizedDepartmentName;
      _departmentInlineEditController.selection = TextSelection.fromPosition(
        TextPosition(offset: _departmentInlineEditController.text.length),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _departmentInlineEditFocusNode.requestFocus();
    });
  }

  void _cancelInlineDepartmentEdit() {
    setState(() {
      _editingDepartmentOfficeId = null;
      _departmentInlineEditController.clear();
    });
  }

  Future<void> _saveInlineDepartmentEdit({
    required OfficeConfig office,
    required String oldDepartmentName,
  }) async {
    final normalizedDepartmentName = _departmentInlineEditController.text
        .trim();
    final validationError = _validateGroupName(normalizedDepartmentName);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            validationError,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    if (normalizedDepartmentName == oldDepartmentName.trim()) {
      _cancelInlineDepartmentEdit();
      return;
    }

    await _controller.updateOfficeDetails(
      officeId: office.officeId,
      newName: office.officeName,
      newGroup: normalizedDepartmentName,
      oldDepartmentName: oldDepartmentName,
      checkInStart: office.policy.checkInStart,
      checkOutEnd: office.policy.checkOutEnd,
      lateBufferMinutes: office.policy.lateBufferMinutes,
      checkOutScanAllowMinutes: office.policy.checkOutScanAllowMinutes,
      annualLeaveLimit: office.policy.annualLeaveLimit,
      sickLeaveLimit: office.policy.sickLeaveLimit,
      botUsername: office.telegramConfig.botUsername,
      botLink: office.telegramConfig.botLink,
    );

    if (!mounted) return;

    setState(() {
      _selectedDepartmentByOfficeId[office.officeId] = normalizedDepartmentName;
      _editingDepartmentOfficeId = null;
      _departmentInlineEditController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(
          AppStrings.tr('office_updated_success'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdownActions({
    required OfficeConfig office,
    required List<String> departments,
    required String selectedDepartment,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInlineEditing = _editingDepartmentOfficeId == office.officeId;

    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              AppStrings.tr('department_label'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: isInlineEditing
                    ? TextField(
                        controller: _departmentInlineEditController,
                        focusNode: _departmentInlineEditFocusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _saveInlineDepartmentEdit(
                          office: office,
                          oldDepartmentName: selectedDepartment,
                        ),
                        decoration: InputDecoration(
                          hintText: AppStrings.tr('department_label'),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDepartment,
                          isExpanded: true,
                          hint: Text(
                            AppStrings.tr('select_department_placeholder'),
                          ),
                          items: departments
                              .map(
                                (department) => DropdownMenuItem<String>(
                                  value: department,
                                  child: Text(
                                    department,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedDepartmentByOfficeId[office.officeId] =
                                  value;
                            });
                          },
                        ),
                      ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.6),
              ),
              if (isInlineEditing) ...[
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: AppStrings.tr('save_changes'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _saveInlineDepartmentEdit(
                    office: office,
                    oldDepartmentName: selectedDepartment,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: AppStrings.tr('cancel'),
                  visualDensity: VisualDensity.compact,
                  onPressed: _cancelInlineDepartmentEdit,
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: AppStrings.tr('edit'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _startInlineDepartmentEdit(office, selectedDepartment),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: AppStrings.tr('delete_department'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showDeleteDepartmentConfirmation(
                    context,
                    office,
                    selectedDepartment,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String? _validateGroupName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) {
      return AppStrings.tr('group_name_required');
    }

    final compactLength = name.replaceAll(RegExp(r'\s+'), '').length;
    if (compactLength < 5) {
      return AppStrings.tr('group_name_min_length');
    }

    return null;
  }

  void _showAddOfficeDialog(BuildContext context) {
    _showOfficeFormDialog(context: context);
  }

  void _showEditOfficeDialog(
    BuildContext context,
    OfficeConfig office, {
    String? preferredDepartment,
  }) {
    _showOfficeFormDialog(
      context: context,
      isEdit: true,
      officeId: office.officeId,
      initialName: office.officeName,
      initialGroup: preferredDepartment ?? office.groupName,
      initialDepartments: office.departments,
      initialCheckIn: office.policy.checkInStart,
      initialCheckOut: office.policy.checkOutEnd,
      initialLateBufferMinutes: office.policy.lateBufferMinutes,
      initialCheckOutScanAllowMinutes: office.policy.checkOutScanAllowMinutes,
      initialAnnualLeave: office.policy.annualLeaveLimit,
      initialSickLeave: office.policy.sickLeaveLimit,
      initialBotUsername: office.telegramConfig.botUsername,
      initialBotLink: office.telegramConfig.botLink,
      initialLat: office.geofence.lat,
      initialLng: office.geofence.lng,
      initialRadiusMeters: office.geofence.radiusMeters,
      initialAddress: office.geofence.addressLabel,
    );
  }

  void _showOfficeFormDialog({
    required BuildContext context,
    bool isEdit = false,
    String? officeId,
    String? initialName,
    String? initialGroup,
    List<String>? initialDepartments,
    String? initialCheckIn,
    String? initialCheckOut,
    int? initialLateBufferMinutes,
    int? initialCheckOutScanAllowMinutes,
    int? initialAnnualLeave,
    int? initialSickLeave,
    String? initialBotUsername,
    String? initialBotLink,
    double? initialLat,
    double? initialLng,
    int? initialRadiusMeters,
    String? initialAddress,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: initialName);
    final officeNameFocusNode = FocusNode();
    final groupCtrl = TextEditingController(text: initialGroup);
    final initialDepartmentsForEdit = <String>{
      ...?initialDepartments,
      if ((initialGroup ?? '').trim().isNotEmpty) initialGroup!.trim(),
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final officeNameSuggestions = _controller.getAllOfficeNames();
    String selectedDepartmentForEdit = (initialGroup ?? '').trim().isNotEmpty
        ? initialGroup!.trim()
        : (initialDepartmentsForEdit.isNotEmpty
              ? initialDepartmentsForEdit.first
              : '');
    bool didInitializeEditDepartment = false;
    final checkInCtrl = TextEditingController(
      text: initialCheckIn ?? '08:00 AM',
    );
    final checkOutCtrl = TextEditingController(
      text: initialCheckOut ?? '05:00 PM',
    );
    final annualLeaveCtrl = TextEditingController(
      text: (initialAnnualLeave ?? 20).toString(),
    );
    final sickLeaveCtrl = TextEditingController(
      text: (initialSickLeave ?? 10).toString(),
    );
    final int initialAllowMinutes = (initialCheckOutScanAllowMinutes ?? 30) > 0
        ? (initialCheckOutScanAllowMinutes ?? 30)
        : 30;
    final bool isInitialPreset =
        initialAllowMinutes == 15 || initialAllowMinutes == 30;
    String selectedCheckOutScanAllowOption = isInitialPreset
        ? initialAllowMinutes.toString()
        : 'custom';
    final customCheckOutScanAllowCtrl = TextEditingController(
      text: isInitialPreset ? '' : initialAllowMinutes.toString(),
    );

    int resolveCheckOutScanAllowMinutes() {
      if (selectedCheckOutScanAllowOption == '15') return 15;
      if (selectedCheckOutScanAllowOption == '30') return 30;
      return int.tryParse(customCheckOutScanAllowCtrl.text.trim()) ?? 0;
    }

    final int initialLateMinutes = (initialLateBufferMinutes ?? 15) > 0
        ? (initialLateBufferMinutes ?? 15)
        : 15;
    final bool isInitialLatePreset =
        initialLateMinutes == 5 || initialLateMinutes == 15;
    String selectedLateBufferOption = isInitialLatePreset
        ? initialLateMinutes.toString()
        : 'custom';
    final customLateBufferCtrl = TextEditingController(
      text: isInitialLatePreset ? '' : initialLateMinutes.toString(),
    );

    int resolveLateBufferMinutes() {
      if (selectedLateBufferOption == '5') return 5;
      if (selectedLateBufferOption == '15') return 15;
      return int.tryParse(customLateBufferCtrl.text.trim()) ?? 0;
    }

    final botUsernameCtrl = TextEditingController(text: initialBotUsername);
    final botLinkCtrl = TextEditingController(text: initialBotLink);
    double? selectedLat = initialLat;
    double? selectedLng = initialLng;
    String selectedAddress = (initialAddress ?? '').trim();
    int selectedRadiusMeters = (initialRadiusMeters ?? 200) > 0
        ? (initialRadiusMeters ?? 200)
        : 200;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final matchedExistingOffice = !isEdit
              ? _controller.findOfficeByName(nameCtrl.text)
              : null;
          final isAddingDepartmentToExistingOffice =
              !isEdit && matchedExistingOffice != null;

          final editDepartmentOptions = isEdit
              ? (officeId == null
                    ? initialDepartmentsForEdit
                    : _controller.getDepartmentsForOffice(officeId))
              : const <String>[];

          if (isEdit && !didInitializeEditDepartment) {
            if (editDepartmentOptions.isNotEmpty &&
                (selectedDepartmentForEdit.isEmpty ||
                    !editDepartmentOptions.contains(
                      selectedDepartmentForEdit,
                    ))) {
              selectedDepartmentForEdit = editDepartmentOptions.first;
            }
            if (groupCtrl.text.trim().isEmpty &&
                selectedDepartmentForEdit.trim().isNotEmpty) {
              groupCtrl.text = selectedDepartmentForEdit;
            }
            didInitializeEditDepartment = true;
          }

          final hasLocation =
              isAddingDepartmentToExistingOffice ||
              (selectedLat != null && selectedLng != null);
          final bool isCustomScanAllowSelected =
              selectedCheckOutScanAllowOption == 'custom';
          final bool isCustomLateBufferSelected =
              selectedLateBufferOption == 'custom';
          final int resolvedCheckOutScanAllowMinutes =
              resolveCheckOutScanAllowMinutes();
          final int resolvedLateBufferMinutes = resolveLateBufferMinutes();
          final scanStartPreview = _getCheckOutScanStartPreview(
            checkOut: checkOutCtrl.text,
            allowMinutes: resolvedCheckOutScanAllowMinutes,
          );
          final lateStartPreview = _getLateStartPreview(
            checkIn: checkInCtrl.text,
            checkOut: checkOutCtrl.text,
            lateBufferMinutes: resolvedLateBufferMinutes,
          );
          final hasAllRequiredData = isAddingDepartmentToExistingOffice
              ? (nameCtrl.text.trim().isNotEmpty &&
                    groupCtrl.text.trim().isNotEmpty)
              : (nameCtrl.text.trim().isNotEmpty &&
                    groupCtrl.text.trim().isNotEmpty &&
                    checkInCtrl.text.trim().isNotEmpty &&
                    checkOutCtrl.text.trim().isNotEmpty &&
                    botUsernameCtrl.text.trim().isNotEmpty &&
                    botLinkCtrl.text.trim().isNotEmpty &&
                    (int.tryParse(annualLeaveCtrl.text.trim()) ?? -1) >= 0 &&
                    (int.tryParse(sickLeaveCtrl.text.trim()) ?? -1) >= 0);
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
                      if (isEdit)
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
                          validator: _validateOfficeName,
                        )
                      else
                        RawAutocomplete<String>(
                          textEditingController: nameCtrl,
                          focusNode: officeNameFocusNode,
                          displayStringForOption: (option) => option,
                          optionsBuilder: (textEditingValue) {
                            final query = textEditingValue.text
                                .trim()
                                .toLowerCase();

                            if (query.isEmpty) {
                              return officeNameSuggestions;
                            }

                            return officeNameSuggestions.where(
                              (officeName) =>
                                  officeName.toLowerCase().contains(query),
                            );
                          },
                          onSelected: (value) {
                            setDialogState(() {
                              nameCtrl.text = value;
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onChanged: (_) => setDialogState(() {}),
                                  decoration: InputDecoration(
                                    labelText: AppStrings.tr('office_label'),
                                    hintText: AppStrings.tr(
                                      'headquarters_example',
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.business_outlined,
                                    ),
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
                                  validator: _validateOfficeName,
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            final optionList = options.toList();
                            if (optionList.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surface,
                                child: SizedBox(
                                  width: 450,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    shrinkWrap: true,
                                    itemCount: optionList.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.3),
                                    ),
                                    itemBuilder: (context, index) {
                                      final officeName = optionList[index];
                                      return ListTile(
                                        dense: true,
                                        leading: Icon(
                                          Icons.apartment_outlined,
                                          color: colorScheme.primary,
                                        ),
                                        title: Text(officeName),
                                        onTap: () => onSelected(officeName),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),

                      if (isEdit && editDepartmentOptions.length > 1) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 230,
                            child: DropdownButtonFormField<String>(
                              value: selectedDepartmentForEdit,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: AppStrings.tr(
                                  'select_department_placeholder',
                                ),
                                prefixIcon: const Icon(Icons.list_alt_outlined),
                                prefixIconColor: colorScheme.primary,
                                filled: true,
                                fillColor: modernFillColor,
                                border: defaultOutlineBorder,
                                enabledBorder: defaultOutlineBorder,
                                focusedBorder: focusedOutlineBorder,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              items: editDepartmentOptions
                                  .map(
                                    (department) => DropdownMenuItem<String>(
                                      value: department,
                                      child: Text(
                                        department,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setDialogState(() {
                                  selectedDepartmentForEdit = value;
                                  groupCtrl.text = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextFormField(
                        controller: groupCtrl,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('department_label'),
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
                        validator: _validateGroupName,
                      ),
                      if (!isEdit && isAddingDepartmentToExistingOffice) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(
                              0.4,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.45),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.merge_type_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  AppStrings.tr(
                                    'existing_office_add_department_hint',
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (!isAddingDepartmentToExistingOffice) ...[
                        TextFormField(
                          controller: checkInCtrl,
                          readOnly: true,
                          onTap: () => _pickTimeForController(
                            context: context,
                            controller: checkInCtrl,
                            setDialogState: setDialogState,
                            fallbackTime: const TimeOfDay(hour: 8, minute: 0),
                          ),
                          decoration: InputDecoration(
                            labelText: AppStrings.tr('policy_check_in_time'),
                            hintText: '08:00 AM',
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
                            fallbackTime: const TimeOfDay(hour: 17, minute: 0),
                          ),
                          decoration: InputDecoration(
                            labelText: AppStrings.tr('policy_check_out_time'),
                            hintText: '05:00 PM',
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
                              : !_isCheckOutAfterCheckIn(
                                  checkIn: checkInCtrl.text,
                                  checkOut: v,
                                )
                              ? AppStrings.tr(
                                  'check_out_must_be_after_check_in',
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _PolicyDropdownField(
                          value: selectedLateBufferOption,
                          labelText: AppStrings.tr('late_consider_time'),
                          prefixIcon: Icons.alarm_outlined,
                          iconColor: colorScheme.primary,
                          fillColor: modernFillColor,
                          defaultBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.tr(
                                'late_consider_time_required',
                              );
                            }

                            if (value != 'custom') {
                              final presetMinutes = int.tryParse(value) ?? 0;
                              if (!_isLateBufferWithinWorkingHours(
                                checkIn: checkInCtrl.text,
                                checkOut: checkOutCtrl.text,
                                lateBufferMinutes: presetMinutes,
                              )) {
                                return AppStrings.tr(
                                  'late_consider_must_before_checkout',
                                );
                              }
                            }

                            return null;
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: '5',
                              child: Text(AppStrings.tr('late_consider_5')),
                            ),
                            DropdownMenuItem<String>(
                              value: '15',
                              child: Text(AppStrings.tr('late_consider_15')),
                            ),
                            DropdownMenuItem<String>(
                              value: 'custom',
                              child: Text(
                                AppStrings.tr('late_consider_custom'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedLateBufferOption = value;
                            });
                          },
                        ),
                        if (isCustomLateBufferSelected) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: customLateBufferCtrl,
                            onChanged: (_) => setDialogState(() {}),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: AppStrings.tr(
                                'late_consider_custom_label',
                              ),
                              hintText: AppStrings.tr(
                                'late_consider_custom_hint',
                              ),
                              prefixIcon: const Icon(Icons.timelapse_outlined),
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
                            validator: (value) {
                              if (!isCustomLateBufferSelected) return null;

                              final raw = (value ?? '').trim();
                              if (raw.isEmpty) {
                                return AppStrings.tr(
                                  'late_consider_custom_required',
                                );
                              }

                              final minutes = int.tryParse(raw);
                              if (minutes == null || minutes <= 0) {
                                return AppStrings.tr(
                                  'late_consider_custom_invalid',
                                );
                              }

                              if (!_isLateBufferWithinWorkingHours(
                                checkIn: checkInCtrl.text,
                                checkOut: checkOutCtrl.text,
                                lateBufferMinutes: minutes,
                              )) {
                                return AppStrings.tr(
                                  'late_consider_must_before_checkout',
                                );
                              }

                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.alarm,
                              size: 14,
                              color: lateStartPreview == null
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                lateStartPreview == null
                                    ? (isCustomLateBufferSelected &&
                                              customLateBufferCtrl.text
                                                  .trim()
                                                  .isEmpty
                                          ? AppStrings.tr(
                                              'late_consider_custom_required',
                                            )
                                          : AppStrings.tr(
                                              'late_consider_must_before_checkout',
                                            ))
                                    : '${AppStrings.tr('late_consider_starts_at')}: $lateStartPreview',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: lateStartPreview == null
                                          ? colorScheme.error
                                          : colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _PolicyDropdownField(
                          value: selectedCheckOutScanAllowOption,
                          labelText: AppStrings.tr('checkout_scan_allow_time'),
                          prefixIcon: Icons.timer_outlined,
                          iconColor: colorScheme.primary,
                          fillColor: modernFillColor,
                          defaultBorder: defaultOutlineBorder,
                          focusedBorder: focusedOutlineBorder,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.tr(
                                'checkout_scan_allow_time_required',
                              );
                            }

                            if (value != 'custom') {
                              final presetMinutes = int.tryParse(value) ?? 0;
                              if (!_isCheckOutScanAllowBeforeCheckOut(
                                checkOut: checkOutCtrl.text,
                                allowMinutes: presetMinutes,
                              )) {
                                return AppStrings.tr(
                                  'checkout_scan_allow_must_before_checkout',
                                );
                              }
                            }

                            return null;
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: '15',
                              child: Text(
                                AppStrings.tr('checkout_scan_allow_15'),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: '30',
                              child: Text(
                                AppStrings.tr('checkout_scan_allow_30'),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'custom',
                              child: Text(
                                AppStrings.tr('checkout_scan_allow_custom'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedCheckOutScanAllowOption = value;
                            });
                          },
                        ),
                        if (isCustomScanAllowSelected) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: customCheckOutScanAllowCtrl,
                            onChanged: (_) => setDialogState(() {}),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: AppStrings.tr(
                                'checkout_scan_allow_custom_label',
                              ),
                              hintText: AppStrings.tr(
                                'checkout_scan_allow_custom_hint',
                              ),
                              prefixIcon: const Icon(Icons.schedule_rounded),
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
                            validator: (value) {
                              if (!isCustomScanAllowSelected) return null;

                              final raw = (value ?? '').trim();
                              if (raw.isEmpty) {
                                return AppStrings.tr(
                                  'checkout_scan_allow_custom_required',
                                );
                              }

                              final minutes = int.tryParse(raw);
                              if (minutes == null || minutes <= 0) {
                                return AppStrings.tr(
                                  'checkout_scan_allow_custom_invalid',
                                );
                              }

                              if (!_isCheckOutScanAllowBeforeCheckOut(
                                checkOut: checkOutCtrl.text,
                                allowMinutes: minutes,
                              )) {
                                return AppStrings.tr(
                                  'checkout_scan_allow_must_before_checkout',
                                );
                              }

                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: scanStartPreview == null
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                scanStartPreview == null
                                    ? (isCustomScanAllowSelected &&
                                              customCheckOutScanAllowCtrl.text
                                                  .trim()
                                                  .isEmpty
                                          ? AppStrings.tr(
                                              'checkout_scan_allow_custom_required',
                                            )
                                          : AppStrings.tr(
                                              'checkout_scan_allow_must_before_checkout',
                                            ))
                                    : '${AppStrings.tr('checkout_scan_start_at')}: $scanStartPreview',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: scanStartPreview == null
                                          ? colorScheme.error
                                          : colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
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
                                  labelText: AppStrings.tr(
                                    'annual_leave_limit',
                                  ),
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
                                              annualLeaveCtrl.text =
                                                  (current + 1).toString();
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
                                    return AppStrings.tr(
                                      'annual_leave_required',
                                    );
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
                        if (!isAddingDepartmentToExistingOffice) ...[
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
                                        selectedAddress =
                                            result['address'] ?? '';
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
                                              ? AppStrings.tr(
                                                  'location_selected',
                                                )
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
                        final resolvedCheckOutScanAllowMinutes =
                            resolveCheckOutScanAllowMinutes();
                        final resolvedLateBufferMinutes =
                            resolveLateBufferMinutes();

                        if (isEdit) {
                          final fallbackAddress =
                              '${AppStrings.tr('latitude')}: ${selectedLat!.toStringAsFixed(4)}, ${AppStrings.tr('longitude')}: ${selectedLng!.toStringAsFixed(4)}';
                          await _controller.updateOfficeDetails(
                            officeId: officeId!,
                            newName: nameCtrl.text,
                            newGroup: groupCtrl.text,
                            oldDepartmentName: selectedDepartmentForEdit,
                            lat: selectedLat,
                            lng: selectedLng,
                            radiusMeters: selectedRadiusMeters,
                            addressLabel: selectedAddress.isNotEmpty
                                ? selectedAddress
                                : fallbackAddress,
                            checkInStart: checkInCtrl.text.trim(),
                            checkOutEnd: checkOutCtrl.text.trim(),
                            lateBufferMinutes: resolvedLateBufferMinutes,
                            checkOutScanAllowMinutes:
                                resolvedCheckOutScanAllowMinutes,
                            annualLeaveLimit: int.parse(
                              annualLeaveCtrl.text.trim(),
                            ),
                            sickLeaveLimit: int.parse(
                              sickLeaveCtrl.text.trim(),
                            ),
                            botUsername: botUsernameCtrl.text.trim(),
                            botLink: botLinkCtrl.text.trim(),
                          );
                        } else if (isAddingDepartmentToExistingOffice) {
                          await _controller.addDepartmentToOffice(
                            officeId: matchedExistingOffice.officeId,
                            departmentName: groupCtrl.text.trim(),
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
                            lateBufferMinutes: resolvedLateBufferMinutes,
                            checkOutScanAllowMinutes:
                                resolvedCheckOutScanAllowMinutes,
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
                                  : isAddingDepartmentToExistingOffice
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
                      : isAddingDepartmentToExistingOffice
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

  void _showDeleteDepartmentConfirmation(
    BuildContext context,
    OfficeConfig office,
    String departmentName,
  ) {
    final departments = _officeDepartments(office);
    if (departments.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            AppStrings.tr('cannot_delete_last_department'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr('delete_department')),
        content: Text(
          '${AppStrings.tr('confirm_delete_department_msg')} $departmentName?',
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
              final isDeleted = await _controller.deleteDepartmentFromOffice(
                officeId: office.officeId,
                departmentName: departmentName,
              );

              if (!context.mounted) return;
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDeleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                  content: Text(
                    isDeleted
                        ? AppStrings.tr('department_deleted_success')
                        : AppStrings.tr('cannot_delete_last_department'),
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
    TimeOfDay fallbackTime = const TimeOfDay(hour: 8, minute: 0),
  }) async {
    final initial = _parseTimeOfDay(controller.text) ?? fallbackTime;
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

  bool _isCheckOutAfterCheckIn({
    required String checkIn,
    required String checkOut,
  }) {
    final checkInTime = _parseTimeOfDay(checkIn);
    final checkOutTime = _parseTimeOfDay(checkOut);
    if (checkInTime == null || checkOutTime == null) {
      return false;
    }

    final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
    final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;
    return checkOutMinutes > checkInMinutes;
  }

  bool _isCheckOutScanAllowBeforeCheckOut({
    required String checkOut,
    required int allowMinutes,
  }) {
    final checkOutTime = _parseTimeOfDay(checkOut);
    if (checkOutTime == null) {
      return false;
    }

    final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;
    return (checkOutMinutes - allowMinutes) >= 0;
  }

  bool _isLateBufferWithinWorkingHours({
    required String checkIn,
    required String checkOut,
    required int lateBufferMinutes,
  }) {
    final checkInTime = _parseTimeOfDay(checkIn);
    final checkOutTime = _parseTimeOfDay(checkOut);
    if (checkInTime == null || checkOutTime == null) {
      return false;
    }

    final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
    final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;
    return (checkInMinutes + lateBufferMinutes) <= checkOutMinutes;
  }

  String? _getCheckOutScanStartPreview({
    required String checkOut,
    required int allowMinutes,
  }) {
    final checkOutTime = _parseTimeOfDay(checkOut);
    if (checkOutTime == null) {
      return null;
    }

    final totalMinutes =
        (checkOutTime.hour * 60 + checkOutTime.minute) - allowMinutes;
    if (totalMinutes < 0) {
      return null;
    }

    final previewTime = TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
    return _formatTimeOfDay12Hour(previewTime);
  }

  String? _getLateStartPreview({
    required String checkIn,
    required String checkOut,
    required int lateBufferMinutes,
  }) {
    if (!_isLateBufferWithinWorkingHours(
      checkIn: checkIn,
      checkOut: checkOut,
      lateBufferMinutes: lateBufferMinutes,
    )) {
      return null;
    }

    final checkInTime = _parseTimeOfDay(checkIn);
    if (checkInTime == null) {
      return null;
    }

    final totalMinutes =
        (checkInTime.hour * 60 + checkInTime.minute) + lateBufferMinutes;
    final previewTime = TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
    return _formatTimeOfDay12Hour(previewTime);
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
                Icons.alarm_on_outlined,
                '${AppStrings.tr('late_consider_label')} ${policy.lateBufferMinutes}m',
              ),
              infoChip(
                Icons.timer_outlined,
                '${AppStrings.tr('checkout_scan_allow_time')} ${policy.checkOutScanAllowMinutes}m',
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

class _PolicyDropdownField extends StatelessWidget {
  const _PolicyDropdownField({
    required this.value,
    required this.labelText,
    required this.prefixIcon,
    required this.iconColor,
    required this.fillColor,
    required this.defaultBorder,
    required this.focusedBorder,
    required this.items,
    required this.validator,
    required this.onChanged,
  });

  final String value;
  final String labelText;
  final IconData prefixIcon;
  final Color iconColor;
  final Color fillColor;
  final InputBorder defaultBorder;
  final InputBorder focusedBorder;
  final List<DropdownMenuItem<String>> items;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        prefixIconColor: iconColor,
        filled: true,
        fillColor: fillColor,
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      validator: validator,
      items: items,
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}
