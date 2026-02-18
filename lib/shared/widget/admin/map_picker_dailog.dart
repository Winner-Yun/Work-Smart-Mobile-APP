import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerDialog extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String initialAddress;

  const MapPickerDialog({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.initialAddress,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng selectedLocation;
  late String selectedAddress;
  late GoogleMapController mapController;

  final TextEditingController searchController = TextEditingController();
  List<geo.Placemark> searchResults = [];
  bool isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    selectedAddress = widget.initialAddress;
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- Search Logic ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      setState(() => isSearching = true);
      try {
        List<geo.Location> locations = await geo.locationFromAddress(query);

        List<geo.Placemark> results = [];
        for (var loc in locations.take(5)) {
          List<geo.Placemark> p = await geo.placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          if (p.isNotEmpty) results.add(p.first);
        }

        if (mounted) {
          setState(() {
            searchResults = results;
            isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isSearching = false;
            searchResults = [];
          });
        }
      }
    });
  }

  // --- Selection Logic ---
  Future<void> _updateLocation(LatLng latLng, {String? manualAddress}) async {
    setState(() => selectedLocation = latLng);
    mapController.animateCamera(CameraUpdate.newLatLng(latLng));

    if (manualAddress != null) {
      setState(() => selectedAddress = manualAddress);
    } else {
      try {
        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          setState(() {
            selectedAddress =
                '${p.street}, ${p.locality}, ${p.administrativeArea}';
          });
        }
      } catch (e) {
        debugPrint("Error getting address: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 900,
          height: 700,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('select_office_location'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.tr('search_or_click_map'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Row(
                  children: [
                    //  Search & Results
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border(
                            right: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: AppStrings.tr('search_address'),
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: theme.scaffoldBackgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  suffixIcon: isSearching
                                      ? Transform.scale(
                                          scale: 0.5,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: searchResults.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 48,
                                            color: theme.dividerColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            AppStrings.tr('no_results_found'),
                                            style: TextStyle(
                                              color: theme.hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: searchResults.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final p = searchResults[index];
                                        final title = p.street ?? p.name ?? '';
                                        final subtitle =
                                            '${p.locality}, ${p.country}';

                                        return ListTile(
                                          leading: const Icon(
                                            Icons.location_on_outlined,
                                          ),
                                          title: Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            subtitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () async {
                                            try {
                                              final locations = await geo
                                                  .locationFromAddress(
                                                    '$title, $subtitle',
                                                  );
                                              if (locations.isNotEmpty) {
                                                _updateLocation(
                                                  LatLng(
                                                    locations.first.latitude,
                                                    locations.first.longitude,
                                                  ),
                                                  manualAddress:
                                                      '$title, $subtitle',
                                                );
                                              }
                                            } catch (e) {
                                              /* ignore */
                                            }
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 7,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: selectedLocation,
                              zoom: 15,
                            ),
                            onMapCreated: (c) => mapController = c,
                            onTap: (loc) => _updateLocation(loc),
                            markers: {
                              Marker(
                                markerId: const MarkerId('selected'),
                                position: selectedLocation,
                              ),
                            },
                            mapToolbarEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('selected_location_label'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress.isNotEmpty
                                ? selectedAddress
                                : "${AppStrings.tr('latitude')}: ${selectedLocation.latitude}, ${AppStrings.tr('longitude')}: ${selectedLocation.longitude}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, {
                          'lat': selectedLocation.latitude,
                          'lng': selectedLocation.longitude,
                          'address': selectedAddress,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(AppStrings.tr('confirm_location')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
