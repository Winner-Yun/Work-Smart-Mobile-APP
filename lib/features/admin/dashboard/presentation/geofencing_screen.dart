import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/geofencing_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';

class GeofencingScreen extends StatefulWidget {
  const GeofencingScreen({super.key});

  @override
  State<GeofencingScreen> createState() => _GeofencingScreenState();
}

class _GeofencingScreenState extends State<GeofencingScreen> {
  late final GeofencingController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = GeofencingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
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
              drawer: isCompact
                  ? Drawer(
                      child: AdminSideBar(
                        isCompact: true,
                        geofencingSelected: true,
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
                      geofencingSelected: true,
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
                      onReportsTap: () =>
                          _navigateTo(AppAdminRoute.analyticsReports),
                      onSettingsTap: () =>
                          _navigateTo(AppAdminRoute.systemSettings),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        AdminHeaderBar(_scaffoldKey),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isCompact ? 16 : 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderSection(),
                                const SizedBox(height: 32),
                                _buildGeofencingStats(),
                                const SizedBox(height: 32),
                                // FIX: Use a SizedBox with fixed height to prevent Expanded error inside ScrollView
                                SizedBox(
                                  height: 700,
                                  child: _buildMainContent(isCompact),
                                ),
                              ],
                            ),
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

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tr('geofencing_management'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        Text(
          AppStrings.tr('geofencing_subtitle'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGeofencingStats() {
    final stats = _controller.getGeofenceStats();
    return Row(
      children: [
        _statCardExpanded(
          'Offices',
          '${stats['totalOffices']}',
          Icons.business_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 20),
        _statCardExpanded(
          'Avg Radius',
          '${stats['avgRadius']}m',
          Icons.radar_rounded,
          Colors.green,
        ),
        const SizedBox(width: 20),
        _statCardExpanded(
          'Min Radius',
          '${stats['minRadius']}m',
          Icons.remove_circle_outline,
          Colors.orange,
        ),
        const SizedBox(width: 20),
        _statCardExpanded(
          'Max Radius',
          '${stats['maxRadius']}m',
          Icons.add_circle_outline,
          Colors.red,
        ),
      ],
    );
  }

  Widget _statCardExpanded(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isCompact) {
    final offices = _controller.getFilteredOffices();
    final selectedOffice = _controller.getSelectedOffice();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: List
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _controller.searchOffices(v)),
                    decoration: InputDecoration(
                      hintText: "Search Office...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: offices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final office = offices[index];
                      final isSelected =
                          office.officeId == _controller.selectedOfficeId;
                      return ListTile(
                        selected: isSelected,
                        onTap: () => setState(
                          () => _controller.selectOffice(office.officeId),
                        ),
                        title: Text(
                          office.officeName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(office.geofence.addressLabel),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Right Column: Detail
        Expanded(
          flex: 6,
          child: selectedOffice == null
              ? const Center(child: Text("Select an office to see details"))
              : _buildDetailView(selectedOffice),
        ),
      ],
    );
  }

  Widget _buildDetailView(OfficeConfig office) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                office.officeName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showEditGeofenceDialog(context, office),
                icon: const Icon(Icons.edit_location_alt_rounded),
                label: const Text("Update Geofence"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _infoTile("Address", office.geofence.addressLabel, Icons.location_on),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  "Latitude",
                  office.geofence.lat.toString(),
                  Icons.map,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoTile(
                  "Longitude",
                  office.geofence.lng.toString(),
                  Icons.explore,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoTile(
            "Radius",
            "${office.geofence.radiusMeters} Meters",
            Icons.radar,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditGeofenceDialog(BuildContext context, OfficeConfig office) {
    final latController = TextEditingController(
      text: office.geofence.lat.toString(),
    );
    final lngController = TextEditingController(
      text: office.geofence.lng.toString(),
    );
    final radiusController = TextEditingController(
      text: office.geofence.radiusMeters.toString(),
    );
    final addressController = TextEditingController(
      text: office.geofence.addressLabel,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${office.officeName} Geofence"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: "Latitude"),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: "Longitude"),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: radiusController,
                decoration: const InputDecoration(labelText: "Radius (meters)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                _controller.updateGeofence(
                  officeId: office.officeId,
                  lat: double.parse(latController.text),
                  lng: double.parse(lngController.text),
                  radiusMeters: int.parse(radiusController.text),
                  addressLabel: addressController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Geofence updated successfully"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid input. Please check your values."),
                  ),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String routeName) {
    if (mounted) {
      Navigator.of(context).pushNamed(routeName);
    }
  }
}
