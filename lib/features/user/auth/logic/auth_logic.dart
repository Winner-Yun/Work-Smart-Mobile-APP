import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';

/// AuthLogic: Core authentication business logic
/// Handles employee login validation, cached credentials, and navigation
class AuthLogic {
  final BuildContext context;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  AuthLogic({
    required this.context,
    required this.usernameController,
    required this.passwordController,
    required this.formKey,
  });

  // ─────────── CACHED LOGIN RETRIEVAL ───────────
  // Checks database for stored credentials and triggers auto-login flow
  Future<void> checkCachedLogin(
    Function(String, String, String) onAutoLogin,
  ) async {
    final dbHelper = DatabaseHelper();
    final cachedLogin = await dbHelper.getCachedLogin();

    if (cachedLogin != null) {
      final username = cachedLogin['username'] as String;
      final userType = cachedLogin['user_type'] as String;
      final userId = cachedLogin['user_id'] as String;

      // Auto-login with cached credentials
      onAutoLogin(username, userId, userType);
    }
  }

  // ─────────── EMPLOYEE LOGIN VALIDATION ───────────
  // Validates username/password against employee database and caches credentials
  Future<bool> handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      // Check employee credentials from userFinalData
      final user = usersFinalData.firstWhere(
        (u) =>
            (u['uid'] == username ||
                u['display_name'].toLowerCase().contains(
                  username.toLowerCase(),
                )) &&
            u['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        _showErrorSnackBar(AppStrings.tr('invalid_credentials'));
        return false;
      }

      // Success - show success message and return user data
      _showSuccessSnackBar(AppStrings.tr('logging_in_employee'));

      // Save login credentials to cache
      final dbHelper = DatabaseHelper();
      dbHelper.saveCachedLogin(username, password, user['uid'], 'employee');

      return true;
    }
    return false;
  }

  // ─────────── NAVIGATION & UI HELPERS ───────────
  // Manages screen navigation, form clearing, and user feedback
  Map<String, dynamic> getLoginData() {
    final username = usernameController.text.trim();
    final user = usersFinalData.firstWhere(
      (u) =>
          (u['uid'] == username ||
          u['display_name'].toLowerCase().contains(username.toLowerCase())),
      orElse: () => {},
    );

    return {'uid': user['uid'], 'username': username, 'userType': 'employee'};
  }

  /// Navigate to main app
  void navigateToMainApp(Map<String, dynamic> loginData) {
    Navigator.pushReplacementNamed(
      context,
      AppRoute.appmain,
      arguments: loginData,
    );
  }

  /// Clear form fields
  void clearForm() {
    usernameController.clear();
    passwordController.clear();
  }

  /// Show error snack bar
  void _showErrorSnackBar(String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Navigate with auto-login flow
  void autoLoginNavigation(String username, String userId, String userType) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.tr('logging_in_employee')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        final loginData = {
          'uid': userId,
          'username': username,
          'userType': userType,
        };

        Navigator.pushReplacementNamed(
          context,
          AppRoute.appmain,
          arguments: loginData,
        );
      }
    });
  }
}
