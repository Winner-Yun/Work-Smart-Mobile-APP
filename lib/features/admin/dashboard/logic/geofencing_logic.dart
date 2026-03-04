import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/geofence.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/policy.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/telegram_config.dart';

class GeofencingController extends ChangeNotifier {
  final List<OfficeConfig> _allOffices = [];

  String? _selectedOfficeId;
  OfficeConfig? _selectedOffice;
  String _searchQuery = '';

  bool _isEditing = false;
  Geofence? _tempGeofence;
  bool _isLoading = false;

  List<OfficeConfig> get allOffices => _allOffices;
  OfficeConfig? get selectedOffice => _selectedOffice;
  String? get selectedOfficeId => _selectedOfficeId;
  String get searchQuery => _searchQuery;
  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  Geofence? get currentGeofence =>
      _isEditing ? _tempGeofence : _selectedOffice?.geofence;

  GeofencingController() {
    _loadOffices();
  }

  void _loadOffices() {
    try {
      final officeConfig = getOfficeConfig();
      _allOffices.clear();
      _allOffices.add(officeConfig);

      if (_allOffices.isNotEmpty) {
        selectOffice(_allOffices.first.officeId);
      }
    } catch (e) {
      if (kDebugMode) print('Error loading offices: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> selectOffice(String officeId) async {
    _setLoading(true);
    if (_isEditing) {
      cancelEdit();
    }
    _selectedOfficeId = officeId;
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
    try {
      _selectedOffice = _allOffices.firstWhere((o) => o.officeId == officeId);
    } catch (e) {
      _selectedOffice = null;
    }
    notifyListeners();
  }

  void searchOffices(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<OfficeConfig> getFilteredOffices() {
    if (_searchQuery.isEmpty) return _allOffices;
    return _allOffices
        .where(
          (office) =>
              office.officeName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              office.groupName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  void startEditing() {
    if (_selectedOffice == null) return;
    _isEditing = true;
    _tempGeofence = _selectedOffice!.geofence;
    notifyListeners();
  }

  void updateTempGeofence({
    double? lat,
    double? lng,
    int? radius,
    String? address,
  }) {
    if (!_isEditing || _tempGeofence == null) return;

    _tempGeofence = Geofence(
      lat: lat ?? _tempGeofence!.lat,
      lng: lng ?? _tempGeofence!.lng,
      radiusMeters: radius ?? _tempGeofence!.radiusMeters,
      addressLabel: address ?? _tempGeofence!.addressLabel,
    );
    notifyListeners();
  }

  void saveChanges() {
    if (!_isEditing || _selectedOffice == null || _tempGeofence == null) return;

    final index = _allOffices.indexWhere(
      (o) => o.officeId == _selectedOfficeId,
    );
    if (index != -1) {
      _allOffices[index] = OfficeConfig(
        officeId: _allOffices[index].officeId,
        officeName: _allOffices[index].officeName,
        groupName: _allOffices[index].groupName,
        geofence: _tempGeofence!,
        policy: _allOffices[index].policy,
        telegramConfig: _allOffices[index].telegramConfig,
      );

      _selectedOffice = _allOffices[index];
    }

    _isEditing = false;
    _tempGeofence = null;
    notifyListeners();
  }

  void cancelEdit() {
    _isEditing = false;
    _tempGeofence = null;
    notifyListeners();
  }

  Map<String, dynamic> getGeofenceStats() {
    if (_allOffices.isEmpty) {
      return {
        'totalOffices': 0,
        'avgRadius': 0,
        'minRadius': 0,
        'maxRadius': 0,
      };
    }

    final radii = _allOffices.map((o) => o.geofence.radiusMeters).toList();

    return {
      'totalOffices': _allOffices.length,
      'avgRadius': (radii.reduce((a, b) => a + b) / _allOffices.length).round(),
      'minRadius': radii.reduce(min),
      'maxRadius': radii.reduce(max),
    };
  }

  Future<void> addNewOffice({
    required String officeName,
    required String groupName,
    required double lat,
    required double lng,
    required int radiusMeters,
    required String addressLabel,
    required String checkInStart,
    required String checkOutEnd,
    required int annualLeaveLimit,
    required int sickLeaveLimit,
    required String botUsername,
    required String botLink,
  }) async {
    try {
      final newOfficeId = 'office_${DateTime.now().millisecondsSinceEpoch}';
      final newGeofence = Geofence(
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
        addressLabel: addressLabel,
      );

      final newOffice = OfficeConfig(
        officeId: newOfficeId,
        officeName: officeName,
        groupName: groupName,
        geofence: newGeofence,
        policy: Policy(
          checkInStart: checkInStart,
          checkOutEnd: checkOutEnd,
          lateBufferMinutes: 15,
          annualLeaveLimit: annualLeaveLimit,
          sickLeaveLimit: sickLeaveLimit,
        ),
        telegramConfig: TelegramConfig(
          botUsername: botUsername,
          botLink: botLink,
          qrCodeData: _generateQrCodeData(botLink, newOfficeId),
        ),
      );

      _allOffices.add(newOffice);
      await selectOffice(newOfficeId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error adding new office: $e');
      rethrow;
    }
  }

  String _generateQrCodeData(String botLink, String officeId) {
    final trimmed = botLink.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('start=')) return trimmed;
    final separator = trimmed.contains('?') ? '&' : '?';
    return '$trimmed${separator}start=$officeId';
  }

  Future<void> updateOfficeDetails({
    required String officeId,
    required String newName,
    required String newGroup,
    required String checkInStart,
    required String checkOutEnd,
    required int annualLeaveLimit,
    required int sickLeaveLimit,
    required String botUsername,
    required String botLink,
  }) async {
    try {
      final index = _allOffices.indexWhere((o) => o.officeId == officeId);
      if (index != -1) {
        final generatedQrCodeData = _generateQrCodeData(botLink, officeId);
        _allOffices[index] = OfficeConfig(
          officeId: _allOffices[index].officeId,
          officeName: newName,
          groupName: newGroup,
          geofence: _allOffices[index].geofence,
          policy: Policy(
            checkInStart: checkInStart,
            checkOutEnd: checkOutEnd,
            lateBufferMinutes: _allOffices[index].policy.lateBufferMinutes,
            annualLeaveLimit: annualLeaveLimit,
            sickLeaveLimit: sickLeaveLimit,
          ),
          telegramConfig: TelegramConfig(
            botUsername: botUsername,
            botLink: botLink,
            qrCodeData: generatedQrCodeData,
          ),
        );

        if (_selectedOfficeId == officeId) {
          _selectedOffice = _allOffices[index];
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error updating office details: $e');
      rethrow;
    }
  }

  Future<void> deleteOffice(String officeId) async {
    try {
      _allOffices.removeWhere((o) => o.officeId == officeId);

      if (_selectedOfficeId == officeId) {
        _selectedOfficeId = null;
        _selectedOffice = null;
        _tempGeofence = null;
        _isEditing = false;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error deleting office: $e');
      rethrow;
    }
  }
}
