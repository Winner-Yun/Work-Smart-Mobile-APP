import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/config/env.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/default_profile_urls.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';

class ManageUsersController extends ChangeNotifier {
  final RealtimeDataController _realtimeDataController;
  final FirebaseAuth _firebaseAuth;

  List<UserEmployee> _allUsers = [];
  List<UserEmployee> _filteredUsers = [];
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedDepartment = 'all';
  bool _isLoading = false;
  StreamSubscription<List<Map<String, dynamic>>>? _userRecordsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _officeRecordsSubscription;
  Map<String, String> _officeNamesById = <String, String>{};
  Map<String, List<String>> _officeDepartmentsById = <String, List<String>>{};

  List<UserEmployee> get filteredUsers => _filteredUsers;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedDepartment => _selectedDepartment;
  bool get isLoading => _isLoading;

  ManageUsersController({RealtimeDataController? realtimeDataController})
    : _realtimeDataController =
          realtimeDataController ?? RealtimeDataController(),
      _firebaseAuth = FirebaseAuth.instance {
    _initializeUsers();
  }

  Future<bool> verifyCurrentAdminPassword(String password) async {
    final trimmedPassword = password.trim();
    if (trimmedPassword.isEmpty) {
      return false;
    }

    final currentUser = _firebaseAuth.currentUser;
    final email = currentUser?.email;
    if (currentUser == null || email == null || email.isEmpty) {
      return false;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: trimmedPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _initializeUsers() async {
    await _runWithLoading(() async {
      final records = await _realtimeDataController.fetchUserRecords();
      _applyIncomingUsers(records);

      final offices = await _realtimeDataController.fetchOfficeConnections();
      _applyIncomingOffices(offices);

      await _userRecordsSubscription?.cancel();
      _userRecordsSubscription = _realtimeDataController
          .watchUserRecords()
          .listen(_applyIncomingUsers);

      await _officeRecordsSubscription?.cancel();
      _officeRecordsSubscription = _realtimeDataController
          .watchOfficeConnections()
          .listen(_applyIncomingOffices);
    });
  }

  void _applyIncomingOffices(List<Map<String, dynamic>> records) {
    final officeNames = <String, String>{};
    final officeDepartments = <String, List<String>>{};

    for (final record in records) {
      final officeId = (record['office_id'] ?? '').toString().trim();
      if (officeId.isEmpty) {
        continue;
      }

      final officeName = (record['office_name'] ?? '').toString().trim();
      final groupName = (record['group_name'] ?? '').toString().trim();

      final departments = <String>{};
      if (groupName.isNotEmpty) {
        departments.add(groupName);
      }

      final rawDepartments = record['departments'];
      if (rawDepartments is List) {
        for (final value in rawDepartments) {
          final department = value?.toString().trim() ?? '';
          if (department.isNotEmpty) {
            departments.add(department);
          }
        }
      }

      officeNames[officeId] = officeName.isEmpty ? officeId : officeName;
      if (departments.isNotEmpty) {
        final sortedDepartments = departments.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        officeDepartments[officeId] = sortedDepartments;
      }
    }

    _officeNamesById = officeNames;
    _officeDepartmentsById = officeDepartments;
    notifyListeners();
  }

  void _applyIncomingUsers(List<Map<String, dynamic>> records) {
    _allUsers = records
        .map((userData) => UserEmployee.fromMap(userData))
        .toList();
    _sortUsersByAddedTime(_allUsers);

    if (_searchQuery.isEmpty &&
        _selectedStatus == 'all' &&
        _selectedDepartment == 'all') {
      _filteredUsers = List.from(_allUsers);
      notifyListeners();
      return;
    }
    _applyFilters();
  }

  void filterUsers(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _runWithLoading(Future<void> Function() operation) async {
    _setLoading(true);
    try {
      await operation();
    } catch (_) {
      return;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setStatus(String status) async {
    _setLoading(true);
    _selectedStatus = status;
    _applyFilters();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  Future<void> setDepartment(String department) async {
    _setLoading(true);
    _selectedDepartment = department;
    _applyFilters();
    await Future.delayed(const Duration(milliseconds: 400));
    _setLoading(false);
  }

  void _applyFilters() {
    _filteredUsers = _allUsers.where((user) {
      // Text search across name, email, uid
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.uid.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus =
          _selectedStatus == 'all' || user.status == _selectedStatus;

      // Department filter
      final matchesDepartment =
          _selectedDepartment == 'all' ||
          user.departmentId == _selectedDepartment;

      return matchesSearch && matchesStatus && matchesDepartment;
    }).toList();

    _sortUsersByAddedTime(_filteredUsers);

    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = 'all';
    _selectedDepartment = 'all';
    _filteredUsers = List.from(_allUsers);
    notifyListeners();
  }

  void _sortUsersByAddedTime(List<UserEmployee> users) {
    users.sort((a, b) {
      final aMillis = a.joinDate?.millisecondsSinceEpoch;
      final bMillis = b.joinDate?.millisecondsSinceEpoch;

      // Newest users first; unknown join dates are pushed to the end.
      if (aMillis != null && bMillis != null) {
        final byDate = bMillis.compareTo(aMillis);
        if (byDate != 0) {
          return byDate;
        }
      } else if (aMillis == null && bMillis != null) {
        return 1;
      } else if (aMillis != null && bMillis == null) {
        return -1;
      }

      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
  }

  Map<String, int> getUserStats() {
    return {
      'total': _allUsers.length,
      'active': _allUsers.where((u) => u.status == 'active').length,
      'inactive': _allUsers.where((u) => u.status == 'inactive').length,
      'suspended': _allUsers.where((u) => u.status == 'suspended').length,
    };
  }

  List<String> getAllDepartments() {
    final departments = _officeDepartmentsById.values
        .expand((values) => values)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    return departments.toList()..sort();
  }

  List<String> getAllOfficeIdsForCreate() {
    final officeIds = _officeNamesById.keys.toList();
    officeIds.sort(
      (a, b) => getOfficeDisplayName(
        a,
      ).toLowerCase().compareTo(getOfficeDisplayName(b).toLowerCase()),
    );
    return officeIds;
  }

  String getOfficeDisplayName(String officeId) {
    final officeKey = officeId.trim();
    if (officeKey.isEmpty) {
      return officeId;
    }
    return _officeNamesById[officeKey] ?? officeKey;
  }

  String? getPreferredDepartmentForOffice(String officeId) {
    final officeKey = officeId.trim();
    if (officeKey.isEmpty) {
      return null;
    }

    final departments = _officeDepartmentsById[officeKey];
    if (departments == null || departments.isEmpty) {
      return null;
    }

    return departments.first;
  }

  List<String> getDepartmentsForOffice(String officeId) {
    final officeKey = officeId.trim();
    if (officeKey.isEmpty) {
      return const <String>[];
    }

    final departments = _officeDepartmentsById[officeKey];
    if (departments == null || departments.isEmpty) {
      return const <String>[];
    }

    return List<String>.from(departments);
  }

  String? getSingleDepartmentForOffice(String officeId) {
    final departments = getDepartmentsForOffice(officeId);
    if (departments.length == 1) {
      return departments.first;
    }
    return null;
  }

  List<String> getDepartmentOptionsForCreate() {
    final departments = _officeDepartmentsById.values
        .expand((values) => values)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final sorted = departments.toList()..sort();
    return sorted;
  }

  Future<void> updateUserStatus(String uid, String newStatus) async {
    await _runWithLoading(() async {
      await _realtimeDataController.updateUserRecord(uid, {
        'status': newStatus,
      });

      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = UserEmployee(
          uid: _allUsers[index].uid,
          displayName: _allUsers[index].displayName,
          roleTitle: _allUsers[index].roleTitle,
          gender: _allUsers[index].gender,
          email: _allUsers[index].email,
          phone: _allUsers[index].phone,
          departmentId: _allUsers[index].departmentId,
          officeId: _allUsers[index].officeId,
          profileUrl: _allUsers[index].profileUrl,
          faceImageUrl: _allUsers[index].faceImageUrl,
          faceImageUrls: _allUsers[index].faceImageUrls,
          faceCount: _allUsers[index].faceCount,
          status: newStatus,
          joinDate: _allUsers[index].joinDate,
          faceStatus: _allUsers[index].faceStatus,
        );
        _applyFilters();
      }
    });
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _runWithLoading(() async {
      await _realtimeDataController.updateUserRecord(uid, {
        'role_title': newRole,
      });

      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = UserEmployee(
          uid: _allUsers[index].uid,
          displayName: _allUsers[index].displayName,
          roleTitle: newRole,
          gender: _allUsers[index].gender,
          email: _allUsers[index].email,
          phone: _allUsers[index].phone,
          departmentId: _allUsers[index].departmentId,
          officeId: _allUsers[index].officeId,
          profileUrl: _allUsers[index].profileUrl,
          faceImageUrl: _allUsers[index].faceImageUrl,
          faceImageUrls: _allUsers[index].faceImageUrls,
          faceCount: _allUsers[index].faceCount,
          status: _allUsers[index].status,
          joinDate: _allUsers[index].joinDate,
          faceStatus: _allUsers[index].faceStatus,
        );
        _applyFilters();
      }
    });
  }

  Future<void> updateUserOfficeAndDepartment({
    required String uid,
    required String officeId,
    required String departmentId,
  }) async {
    await _runWithLoading(() async {
      await _realtimeDataController.updateUserRecord(uid, {
        'office_id': officeId,
        'department_id': departmentId,
      });

      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = UserEmployee(
          uid: _allUsers[index].uid,
          displayName: _allUsers[index].displayName,
          roleTitle: _allUsers[index].roleTitle,
          gender: _allUsers[index].gender,
          email: _allUsers[index].email,
          phone: _allUsers[index].phone,
          departmentId: departmentId,
          officeId: officeId,
          profileUrl: _allUsers[index].profileUrl,
          faceImageUrl: _allUsers[index].faceImageUrl,
          faceImageUrls: _allUsers[index].faceImageUrls,
          faceCount: _allUsers[index].faceCount,
          status: _allUsers[index].status,
          joinDate: _allUsers[index].joinDate,
          faceStatus: _allUsers[index].faceStatus,
        );
        _applyFilters();
      }
    });
  }

  Future<void> removeUser(String uid) async {
    await _runWithLoading(() async {
      await _realtimeDataController.deleteUserRecord(uid);
      _allUsers.removeWhere((u) => u.uid == uid);
      _applyFilters();
    });
  }

  Future<void> createUser({
    required String uid,
    required String displayName,
    required String roleTitle,
    String? password,
    required String gender,
    required String email,
    required String phone,
    required String departmentId,
    required String officeId,
    String? profileUrl,
    String status = 'active',
  }) async {
    await _runWithLoading(() async {
      final normalizedUid = uid.trim();
      final normalizedOfficeId = officeId.trim();
      final preferredDepartment = getPreferredDepartmentForOffice(
        normalizedOfficeId,
      );
      final normalizedDepartment = departmentId.trim().isEmpty
          ? (preferredDepartment ?? '')
          : departmentId.trim();
      final resolvedProfileUrl = DefaultProfileUrls.resolve(
        gender: gender,
        providedUrl: profileUrl,
      );

      final resolvedPassword = (password == null || password.trim().isEmpty)
          ? Env.defaultUserPassword.trim()
          : password.trim();
      final normalizedEmail = email.trim().toLowerCase();

      await _createFirebaseAuthUser(
        email: normalizedEmail,
        password: resolvedPassword,
        displayName: displayName,
      );

      final newUserMap = {
        'uid': normalizedUid,
        'display_name': displayName,
        'role_title': roleTitle,
        'gender': gender,
        'email': normalizedEmail,
        'phone': phone,
        'department_id': normalizedDepartment,
        'office_id': normalizedOfficeId,
        'profile_url': resolvedProfileUrl,
        'status': status,
        'password': resolvedPassword,
        'join_date': DateTime.now().toIso8601String(),
        'biometrics': {
          'face_status': 'uninitialized',
          'face_count': 0,
          'face_image_urls': <String>[],
        },
      };

      await _realtimeDataController.upsertUserRecord(newUserMap);

      final newUser = UserEmployee(
        uid: normalizedUid,
        displayName: displayName,
        roleTitle: roleTitle,
        gender: gender,
        email: normalizedEmail,
        phone: phone,
        departmentId: normalizedDepartment,
        officeId: normalizedOfficeId,
        profileUrl: resolvedProfileUrl,
        faceImageUrl: '',
        faceImageUrls: const [],
        faceCount: 0,
        status: status,
        joinDate: DateTime.now(),
        faceStatus: 'uninitialized',
      );

      final existingIndex = _allUsers.indexWhere(
        (user) => user.uid == normalizedUid,
      );
      if (existingIndex >= 0) {
        _allUsers[existingIndex] = newUser;
      } else {
        _allUsers.add(newUser);
      }

      _sortUsersByAddedTime(_allUsers);
      _applyFilters();
    });
  }

  Future<void> _createFirebaseAuthUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();
    if (normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      return;
    }

    FirebaseApp? tempApp;
    FirebaseAuth? tempAuth;

    try {
      final defaultApp = Firebase.app();
      tempApp = await Firebase.initializeApp(
        name: 'manage_users_create_${DateTime.now().microsecondsSinceEpoch}',
        options: defaultApp.options,
      );
      tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: trimmedPassword,
      );
      await userCredential.user?.updateDisplayName(displayName.trim());
    } on FirebaseAuthException catch (e) {
      // If email already exists, authentication record is already available.
      if (e.code != 'email-already-in-use') {
        rethrow;
      }
    } finally {
      try {
        await tempAuth?.signOut();
      } catch (_) {
        // Ignore cleanup failures.
      }
      try {
        await tempApp?.delete();
      } catch (_) {
        // Ignore cleanup failures.
      }
    }
  }

  @override
  void dispose() {
    _userRecordsSubscription?.cancel();
    _officeRecordsSubscription?.cancel();
    super.dispose();
  }
}
