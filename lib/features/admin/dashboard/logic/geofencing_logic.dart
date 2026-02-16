import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/geofence.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';

class GeofencingController extends ChangeNotifier {
  final List<OfficeConfig> _allOffices = [];
  late Geofence _selectedGeofence;
  String _selectedOfficeId = '';
  String _searchQuery = '';

  List<OfficeConfig> get allOffices => _allOffices;
  Geofence get selectedGeofence => _selectedGeofence;
  String get selectedOfficeId => _selectedOfficeId;
  String get searchQuery => _searchQuery;

  GeofencingController() {
    _loadOffices();
  }

  void _loadOffices() {
    try {
      final officeConfig = getOfficeConfig();
      _allOffices.clear();
      _allOffices.add(officeConfig);

      if (_allOffices.isNotEmpty) {
        _selectedOfficeId = _allOffices.first.officeId;
        _selectedGeofence = _allOffices.first.geofence;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading offices: $e');
      }
    }
  }

  void selectOffice(String officeId) {
    _selectedOfficeId = officeId;
    final office = _allOffices.firstWhere(
      (o) => o.officeId == officeId,
      orElse: () => _allOffices.first,
    );
    _selectedGeofence = office.geofence;
    notifyListeners();
  }

  void searchOffices(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<OfficeConfig> getFilteredOffices() {
    if (_searchQuery.isEmpty) {
      return _allOffices;
    }
    return _allOffices
        .where(
          (office) =>
              office.officeName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              office.officeId.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  OfficeConfig? getSelectedOffice() {
    try {
      return _allOffices.firstWhere((o) => o.officeId == _selectedOfficeId);
    } catch (e) {
      if (kDebugMode) print('Selected office not found: $e');
      return null;
    }
  }

  Future<void> updateGeofence({
    required String officeId,
    required double lat,
    required double lng,
    required int radiusMeters,
    required String addressLabel,
  }) async {
    try {
      final index = _allOffices.indexWhere((o) => o.officeId == officeId);
      if (index != -1) {
        final updatedGeofence = Geofence(
          lat: lat,
          lng: lng,
          radiusMeters: radiusMeters,
          addressLabel: addressLabel,
        );

        _allOffices[index] = OfficeConfig(
          officeId: _allOffices[index].officeId,
          officeName: _allOffices[index].officeName,
          groupName: _allOffices[index].groupName,
          geofence: updatedGeofence,
          policy: _allOffices[index].policy,
          telegramConfig: _allOffices[index].telegramConfig,
        );

        if (_selectedOfficeId == officeId) {
          _selectedGeofence = updatedGeofence;
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error updating geofence: $e');
    }
  }

  Map<String, dynamic> getGeofenceStats() {
    return {
      'totalOffices': _allOffices.length,
      'avgRadius': _allOffices.isEmpty
          ? 0
          : _allOffices.fold<int>(
                  0,
                  (sum, office) => sum + office.geofence.radiusMeters,
                ) ~/
                _allOffices.length,
      'minRadius': _allOffices.isEmpty
          ? 0
          : _allOffices
                .map((o) => o.geofence.radiusMeters)
                .reduce((a, b) => a < b ? a : b),
      'maxRadius': _allOffices.isEmpty
          ? 0
          : _allOffices
                .map((o) => o.geofence.radiusMeters)
                .reduce((a, b) => a > b ? a : b),
    };
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int R = 6371; // Radius of the earth in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c; // Distance in km
    return distance * 1000; // Convert to meters
  }

  double _deg2rad(double deg) {
    return deg * (3.14159265359 / 180);
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
