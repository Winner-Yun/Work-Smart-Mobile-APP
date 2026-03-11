import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/auth/controller/admin_auth_controller.dart';

class AuthAdminLogic {
  final BuildContext context;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final AdminAuthController _adminAuthController;

  AuthAdminLogic({
    required this.context,
    required this.usernameController,
    required this.passwordController,
    required this.formKey,
    AdminAuthController? adminAuthController,
  }) : _adminAuthController = adminAuthController ?? AdminAuthController();

  /// Automatically trigger the creation of the default admin in Firebase
  Future<void> seedDatabase() async {
    await _adminAuthController.seedDefaultAdmin();
  }

  /// Uses Firebase persisted auth state for admin auto-login.
  Future<void> checkCachedLogin(Function(String, String) onAutoLogin) async {
    try {
      if (!_adminAuthController.hasAuthenticatedSession) {
        return;
      }

      if (_adminAuthController.isAuthenticatedSessionExpired(
        maxSessionAge: const Duration(days: 1),
      )) {
        await _adminAuthController.signOut();
        return;
      }

      final username = _adminAuthController.getPersistedAdminUsername();
      if (username == null || username.trim().isEmpty) {
        return;
      }

      onAutoLogin(username, 'admin');
    } catch (_) {
      return;
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
    final usernameForStorage = username.toLowerCase() == 'admin'
        ? 'Admin'
        : username;

    // 2. Credential Verification (Talk to Firebase)
    final isValid = await _adminAuthController.verifyAdminCredentials(
      username: username,
      password: password,
    );

    if (!isValid) {
      _showSnackBar(
        message: AppStrings.tr('invalid_credentials'),
        isError: true,
      );
      return false;
    }

    // 3. Success - Update history
    try {
      var isFirebaseSynced = true;
      try {
        await _adminAuthController.storeAdminLoginAccount(
          username: usernameForStorage,
        );
      } catch (_) {
        isFirebaseSynced = false;
      }

      _showSnackBar(
        message: isFirebaseSynced
            ? "${AppStrings.tr('logging_in_admin')}..."
            : 'Login successful, Firebase sync pending.',
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
    Navigator.pushReplacementNamed(context, AppAdminRoute.adminDashboard);
  }

  void autoLoginNavigation(String username, String userType) {
    if (!context.mounted) return;

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

  void _showSnackBar({required String message, required bool isError}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError
            ? Colors.red.shade600
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
