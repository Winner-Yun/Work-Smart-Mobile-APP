import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';

class ManageUsersController extends ChangeNotifier {
  List<UserEmployee> _allUsers = [];
  List<UserEmployee> _filteredUsers = [];
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedDepartment = 'all';

  List<UserEmployee> get filteredUsers => _filteredUsers;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedDepartment => _selectedDepartment;

  ManageUsersController() {
    _loadUsers();
  }

  void _loadUsers() {
    try {
      _allUsers = usersFinalData
          .map((userData) => UserEmployee.fromMap(userData))
          .toList();
      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    }
  }

  void filterUsers(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void setDepartment(String department) {
    _selectedDepartment = department;
    _applyFilters();
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

    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = 'all';
    _selectedDepartment = 'all';
    _filteredUsers = List.from(_allUsers);
    notifyListeners();
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
    final departments = <String>{};
    for (var user in _allUsers) {
      departments.add(user.departmentId);
    }
    return departments.toList()..sort();
  }

  Future<void> updateUserStatus(String uid, String newStatus) async {
    try {
      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = UserEmployee(
          uid: _allUsers[index].uid,
          displayName: _allUsers[index].displayName,
          roleTitle: _allUsers[index].roleTitle,
          email: _allUsers[index].email,
          phone: _allUsers[index].phone,
          departmentId: _allUsers[index].departmentId,
          officeId: _allUsers[index].officeId,
          profileUrl: _allUsers[index].profileUrl,
          status: newStatus,
          joinDate: _allUsers[index].joinDate,
          faceStatus: _allUsers[index].faceStatus,
        );
        _applyFilters();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user status: $e');
      }
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      final index = _allUsers.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _allUsers[index] = UserEmployee(
          uid: _allUsers[index].uid,
          displayName: _allUsers[index].displayName,
          roleTitle: newRole,
          email: _allUsers[index].email,
          phone: _allUsers[index].phone,
          departmentId: _allUsers[index].departmentId,
          officeId: _allUsers[index].officeId,
          profileUrl: _allUsers[index].profileUrl,
          status: _allUsers[index].status,
          joinDate: _allUsers[index].joinDate,
          faceStatus: _allUsers[index].faceStatus,
        );
        _applyFilters();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user role: $e');
      }
    }
  }

  void removeUser(String uid) {
    try {
      _allUsers.removeWhere((u) => u.uid == uid);
      _applyFilters();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing user: $e');
      }
    }
  }

  Future<void> createUser({
    required String uid,
    required String displayName,
    required String roleTitle,
    required String email,
    required String phone,
    required String departmentId,
    required String officeId,
    String profileUrl =
        'https://res.cloudinary.com/dwrf0xt1x/image/upload/v1770293036/default_profile.jpg',
    String status = 'active',
  }) async {
    try {
      final newUser = UserEmployee(
        uid: uid,
        displayName: displayName,
        roleTitle: roleTitle,
        email: email,
        phone: phone,
        departmentId: departmentId,
        officeId: officeId,
        profileUrl: profileUrl,
        status: status,
        joinDate: DateTime.now(),
        faceStatus: 'pending',
      );

      _allUsers.add(newUser);
      _applyFilters();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }
    }
  }
}
