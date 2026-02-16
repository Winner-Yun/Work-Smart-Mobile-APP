import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';

class AuthAdminLogic {
  final BuildContext context;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  // Hardcoded for demo/MVP purposes
  static const Map<String, String> _adminUsers = {
    'admin': 'admin123',
    'manager': 'manager123',
  };

  AuthAdminLogic({
    required this.context,
    required this.usernameController,
    required this.passwordController,
    required this.formKey,
  });

  /// Checks the local database for a saved session
  Future<void> checkCachedLogin(Function(String, String) onAutoLogin) async {
    try {
      final dbHelper = DatabaseHelper();
      final cachedLogin = await dbHelper.getCachedLogin();

      if (cachedLogin != null) {
        final username = cachedLogin['username'] as String?;
        final userType = cachedLogin['user_type'] as String?;
        final password = cachedLogin['password'] as String?;

        if (username != null && userType == 'admin' && password != null) {
          // Verify if credentials are still valid in our "database"
          if (_adminUsers[username] == password) {
            onAutoLogin(username, userType!);
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking cached login: $e");
    }
  }

  /// Processes the login attempt
  Future<bool> handleLogin() async {
    // 1. Basic Form Validation
    if (formKey.currentState?.validate() != true) {
      return false;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // 2. Credential Verification
    if (!_adminUsers.containsKey(username) ||
        _adminUsers[username] != password) {
      _showSnackBar(
        message: AppStrings.tr('invalid_credentials'),
        isError: true,
      );
      return false;
    }

    // 3. Success - Cache Session
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.saveCachedLogin(username, password, username, 'admin');

      _showSnackBar(
        message: "${AppStrings.tr('logging_in_admin')}...",
        isError: false,
      );

      return true;
    } catch (e) {
      _showSnackBar(message: "Database Error: $e", isError: true);
      return false;
    }
  }

  void navigateToAdminPanel() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppAdminRoute.adminTutorial);
  }

  void autoLoginNavigation(String username, String userType) {
    if (!context.mounted) return;

    // Slight delay to ensure context is ready and UI has rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        _showSnackBar(message: "Welcome back, $username", isError: false);
        navigateToAdminPanel();
      }
    });
  }

  void clearForm() {
    usernameController.clear();
    passwordController.clear();
  }

  // ─── Validation Helpers ───

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.tr('username_required');
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.tr('password_required');
    }
    return null;
  }

  // ─── Private UI Helpers ───

  void _showSnackBar({required String message, required bool isError}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade600
            : const Color(0xFF111827),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
