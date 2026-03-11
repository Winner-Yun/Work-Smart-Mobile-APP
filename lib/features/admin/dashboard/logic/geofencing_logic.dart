import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/geofence.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/office_config.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/policy.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/office_model/telegram_config.dart';

class GeofencingController extends ChangeNotifier {
  final RealtimeDataController _realtimeDataController;
  final List<OfficeConfig> _allOffices = [];
  StreamSubscription<List<Map<String, dynamic>>>? _officesSubscription;

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

  GeofencingController({RealtimeDataController? realtimeDataController})
    : _realtimeDataController =
          realtimeDataController ?? RealtimeDataController() {
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    try {
      final remoteOffices = await _realtimeDataController
          .fetchOfficeConnections();
      if (remoteOffices.isNotEmpty) {
        _applyRealtimeOffices(
          remoteOffices.map(OfficeConfig.fromJson).toList(),
        );
      } else {
        final fallbackOffice = getOfficeConfig();
        if (fallbackOffice.officeId.isNotEmpty ||
            fallbackOffice.officeName.isNotEmpty) {
          _applyRealtimeOffices(<OfficeConfig>[fallbackOffice]);
        } else {
          _applyRealtimeOffices(const <OfficeConfig>[]);
        }
      }

      _subscribeToOffices();
    } catch (_) {
      final fallbackOffice = getOfficeConfig();
      if (fallbackOffice.officeId.isNotEmpty ||
          fallbackOffice.officeName.isNotEmpty) {
        _applyRealtimeOffices(<OfficeConfig>[fallbackOffice]);
      } else {
        _applyRealtimeOffices(const <OfficeConfig>[]);
      }
    }
  }

  void _applyRealtimeOffices(List<OfficeConfig> offices) {
    final mergedOffices = _mergeOfficesByName(offices);
    final sortedOffices = List<OfficeConfig>.from(mergedOffices)
      ..sort(
        (a, b) =>
            a.officeName.toLowerCase().compareTo(b.officeName.toLowerCase()),
      );

    _allOffices
      ..clear()
      ..addAll(sortedOffices);

    if (_allOffices.isEmpty) {
      _selectedOfficeId = null;
      _selectedOffice = null;
      _tempGeofence = null;
      _isEditing = false;
      notifyListeners();
      return;
    }

    final hasCurrentSelection =
        _selectedOfficeId != null &&
        _allOffices.any((office) => office.officeId == _selectedOfficeId);

    if (!hasCurrentSelection) {
      _selectedOfficeId = _allOffices.first.officeId;
    }

    _selectedOffice = _allOffices.firstWhere(
      (office) => office.officeId == _selectedOfficeId,
    );

    if (_isEditing && _selectedOffice != null) {
      _tempGeofence ??= _selectedOffice!.geofence;
    }

    notifyListeners();
  }

  void _subscribeToOffices() {
    _officesSubscription?.cancel();
    _officesSubscription = _realtimeDataController
        .watchOfficeConnections()
        .listen((offices) {
          _applyRealtimeOffices(offices.map(OfficeConfig.fromJson).toList());
        });
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
    final normalizedQuery = _searchQuery.toLowerCase();

    return _allOffices
        .where(
          (office) =>
              office.officeName.toLowerCase().contains(normalizedQuery) ||
              office.groupName.toLowerCase().contains(normalizedQuery) ||
              office.departments.any(
                (department) =>
                    department.toLowerCase().contains(normalizedQuery),
              ),
        )
        .toList();
  }

  List<String> getAllOfficeNames() {
    final names = _allOffices
        .map((office) => office.officeName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  OfficeConfig? findOfficeByName(String officeName) {
    final normalizedName = _normalizeOfficeName(officeName);
    if (normalizedName.isEmpty) {
      return null;
    }

    final matched = _allOffices.where(
      (office) => _normalizeOfficeName(office.officeName) == normalizedName,
    );

    if (matched.isEmpty) {
      return null;
    }

    return matched.first;
  }

  List<String> getDepartmentsForOffice(String officeId) {
    final matched = _allOffices.where((office) => office.officeId == officeId);
    if (matched.isEmpty) {
      return <String>[];
    }

    final office = matched.first;
    final departments = <String>{
      ...office.departments.map((value) => value.trim()),
      office.groupName.trim(),
    }.where((value) => value.isNotEmpty).toList();

    departments.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return departments;
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

  Future<void> saveChanges() async {
    if (!_isEditing || _selectedOffice == null || _tempGeofence == null) return;

    final index = _allOffices.indexWhere(
      (o) => o.officeId == _selectedOfficeId,
    );
    if (index != -1) {
      _allOffices[index] = _allOffices[index].copyWith(geofence: _tempGeofence);

      _selectedOffice = _allOffices[index];
      await _realtimeDataController.upsertOfficeConnection(
        _allOffices[index].toJson(),
        officeId: _allOffices[index].officeId,
      );
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
    required int lateBufferMinutes,
    required int checkOutScanAllowMinutes,
    required int annualLeaveLimit,
    required int sickLeaveLimit,
    required String botUsername,
    required String botLink,
  }) async {
    try {
      final normalizedOfficeName = officeName.trim();
      final normalizedGroupName = groupName.trim();
      final normalizedLateBufferMinutes = lateBufferMinutes > 0
          ? lateBufferMinutes
          : 15;
      final normalizedAllowMinutes = checkOutScanAllowMinutes > 0
          ? checkOutScanAllowMinutes
          : 30;
      final newOfficeId = 'office_${DateTime.now().millisecondsSinceEpoch}';
      final newGeofence = Geofence(
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
        addressLabel: addressLabel,
      );

      final newOffice = OfficeConfig(
        officeId: newOfficeId,
        officeName: normalizedOfficeName,
        groupName: normalizedGroupName,
        departments: <String>[normalizedGroupName],
        geofence: newGeofence,
        policy: Policy(
          checkInStart: checkInStart,
          checkOutEnd: checkOutEnd,
          lateBufferMinutes: normalizedLateBufferMinutes,
          checkOutScanAllowMinutes: normalizedAllowMinutes,
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
      await _realtimeDataController.upsertOfficeConnection(
        newOffice.toJson(),
        officeId: newOfficeId,
      );
      await selectOffice(newOfficeId);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> addDepartmentToOffice({
    required String officeId,
    required String departmentName,
  }) async {
    final normalizedOfficeId = officeId.trim();
    final normalizedDepartmentName = departmentName.trim();
    if (normalizedOfficeId.isEmpty || normalizedDepartmentName.isEmpty) {
      return;
    }

    final index = _allOffices.indexWhere(
      (office) => office.officeId == officeId,
    );
    if (index == -1) {
      return;
    }

    final office = _allOffices[index];
    final departments = <String>{
      ...office.departments.map((value) => value.trim()),
      office.groupName.trim(),
      normalizedDepartmentName,
    }.where((value) => value.isNotEmpty).toList();
    departments.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final updatedOffice = office.copyWith(
      groupName: normalizedDepartmentName,
      departments: departments,
    );

    _allOffices[index] = updatedOffice;
    if (_selectedOfficeId == updatedOffice.officeId) {
      _selectedOffice = updatedOffice;
    }

    await _realtimeDataController.upsertOfficeConnection(
      updatedOffice.toJson(),
      officeId: updatedOffice.officeId,
    );

    notifyListeners();
  }

  Future<bool> deleteDepartmentFromOffice({
    required String officeId,
    required String departmentName,
  }) async {
    final normalizedOfficeId = officeId.trim();
    final normalizedDepartmentName = departmentName.trim();
    if (normalizedOfficeId.isEmpty || normalizedDepartmentName.isEmpty) {
      return false;
    }

    final index = _allOffices.indexWhere(
      (office) => office.officeId == normalizedOfficeId,
    );
    if (index == -1) {
      return false;
    }

    final office = _allOffices[index];
    final existingDepartments = <String>{
      ...office.departments.map((value) => value.trim()),
      office.groupName.trim(),
    }.where((value) => value.isNotEmpty).toList();
    existingDepartments.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );

    final targetLower = normalizedDepartmentName.toLowerCase();
    final hasTarget = existingDepartments.any(
      (value) => value.toLowerCase() == targetLower,
    );
    if (!hasTarget || existingDepartments.length <= 1) {
      return false;
    }

    final remainingDepartments = existingDepartments
        .where((value) => value.toLowerCase() != targetLower)
        .toList();
    if (remainingDepartments.isEmpty) {
      return false;
    }

    final currentGroupLower = office.groupName.trim().toLowerCase();
    final nextGroupName = currentGroupLower == targetLower
        ? remainingDepartments.first
        : office.groupName.trim();

    final updatedOffice = office.copyWith(
      groupName: nextGroupName,
      departments: remainingDepartments,
    );

    _allOffices[index] = updatedOffice;
    if (_selectedOfficeId == updatedOffice.officeId) {
      _selectedOffice = updatedOffice;
    }

    await _realtimeDataController.upsertOfficeConnection(
      updatedOffice.toJson(),
      officeId: updatedOffice.officeId,
    );

    notifyListeners();
    return true;
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
    String? oldDepartmentName,
    required String checkInStart,
    required String checkOutEnd,
    required int lateBufferMinutes,
    required int checkOutScanAllowMinutes,
    required int annualLeaveLimit,
    required int sickLeaveLimit,
    required String botUsername,
    required String botLink,
  }) async {
    try {
      final normalizedOfficeName = newName.trim();
      final normalizedGroupName = newGroup.trim();
      final normalizedOldDepartmentName = oldDepartmentName?.trim() ?? '';
      final normalizedLateBufferMinutes = lateBufferMinutes > 0
          ? lateBufferMinutes
          : 15;
      final normalizedAllowMinutes = checkOutScanAllowMinutes > 0
          ? checkOutScanAllowMinutes
          : 30;
      final index = _allOffices.indexWhere((o) => o.officeId == officeId);
      if (index != -1) {
        final existingOffice = _allOffices[index];

        final mutableDepartments = <String>{
          ...existingOffice.departments.map((value) => value.trim()),
          existingOffice.groupName.trim(),
        }.where((value) => value.isNotEmpty).toList();

        if (normalizedOldDepartmentName.isNotEmpty) {
          final oldIndex = mutableDepartments.indexWhere(
            (value) =>
                value.toLowerCase() ==
                normalizedOldDepartmentName.toLowerCase(),
          );
          if (oldIndex != -1) {
            mutableDepartments[oldIndex] = normalizedGroupName;
          } else if (normalizedGroupName.isNotEmpty) {
            mutableDepartments.add(normalizedGroupName);
          }
        } else if (normalizedGroupName.isNotEmpty) {
          mutableDepartments.add(normalizedGroupName);
        }

        final deduplicatedDepartments = <String>{
          for (final value in mutableDepartments)
            if (value.trim().isNotEmpty) value.trim(),
        }.toList();
        deduplicatedDepartments.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );

        final resolvedGroupName = normalizedGroupName.isNotEmpty
            ? normalizedGroupName
            : (deduplicatedDepartments.isNotEmpty
                  ? deduplicatedDepartments.first
                  : '');

        final generatedQrCodeData = _generateQrCodeData(botLink, officeId);
        _allOffices[index] = OfficeConfig(
          officeId: existingOffice.officeId,
          officeName: normalizedOfficeName,
          groupName: resolvedGroupName,
          departments: deduplicatedDepartments,
          geofence: existingOffice.geofence,
          policy: Policy(
            checkInStart: checkInStart,
            checkOutEnd: checkOutEnd,
            lateBufferMinutes: normalizedLateBufferMinutes,
            checkOutScanAllowMinutes: normalizedAllowMinutes,
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

        await _realtimeDataController.upsertOfficeConnection(
          _allOffices[index].toJson(),
          officeId: _allOffices[index].officeId,
        );
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  List<OfficeConfig> _mergeOfficesByName(List<OfficeConfig> offices) {
    final mergedByName = <String, OfficeConfig>{};

    for (final office in offices) {
      final officeName = office.officeName.trim();
      final key = _normalizeOfficeName(
        officeName.isNotEmpty ? officeName : office.officeId,
      );
      final existing = mergedByName[key];
      if (existing == null) {
        mergedByName[key] = office;
        continue;
      }

      final mergedDepartments = <String>{
        ...existing.departments.map((value) => value.trim()),
        existing.groupName.trim(),
        ...office.departments.map((value) => value.trim()),
        office.groupName.trim(),
      }.where((value) => value.isNotEmpty).toList();
      mergedDepartments.sort(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );

      final resolvedGroupName = existing.groupName.trim().isNotEmpty
          ? existing.groupName.trim()
          : (office.groupName.trim().isNotEmpty
                ? office.groupName.trim()
                : (mergedDepartments.isNotEmpty
                      ? mergedDepartments.first
                      : ''));

      mergedByName[key] = existing.copyWith(
        groupName: resolvedGroupName,
        departments: mergedDepartments,
      );
    }

    return mergedByName.values.toList();
  }

  String _normalizeOfficeName(String value) {
    return value.trim().toLowerCase();
  }

  Future<void> deleteOffice(String officeId) async {
    try {
      await _realtimeDataController.deleteOfficeConnection(officeId);
      _allOffices.removeWhere((o) => o.officeId == officeId);

      if (_selectedOfficeId == officeId) {
        _selectedOfficeId = null;
        _selectedOffice = null;
        _tempGeofence = null;
        _isEditing = false;
      }
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _officesSubscription?.cancel();
    super.dispose();
  }
}
