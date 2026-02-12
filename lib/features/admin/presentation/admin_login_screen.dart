import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

/// AdminLoginScreen: Web-only admin login interface
/// Provides hardcoded admin/manager credentials for web access
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  // ─────────── ADMIN CREDENTIALS ───────────
  // Hardcoded admin and manager credentials for demo/testing
  static const Map<String, String> adminUsers = {
    'admin': 'admin123',
    'manager': 'manager123',
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ──────────────── ADMIN LOGIN PROCESSING ────────────────
  // Validates hardcoded admin credentials and navigates to dashboard
  Future<void> _handleAdminLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      await Future.delayed(const Duration(milliseconds: 800));

      // Validate admin credentials
      if (adminUsers.containsKey(username) &&
          adminUsers[username] == password) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.tr('logging_in_admin')),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            final loginData = {
              'uid': username,
              'username': username,
              'userType': 'admin',
            };

            Navigator.pushReplacementNamed(
              context,
              AppRoute.adminDashboardWeb,
              arguments: loginData,
            );
          }
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.tr('invalid_credentials')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // ──────────────── ADMIN LOGIN UI ────────────────
  // Renders admin login form with animated background and credentials hint
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImg.authBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Background gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              // Main content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Logo and title
                      Column(
                        children: [
                          Text(
                            'WorkSmart',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Admin Portal',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white70),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                      const SizedBox(height: 80),
                      // Login form card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: theme.cardTheme.color,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Login',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ).animate().fadeIn(delay: 300.ms),
                                const SizedBox(height: 24),

                                // Username field
                                Text(
                                  'Username',
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter admin username',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username is required';
                                    }
                                    return null;
                                  },
                                ).animate().fadeIn(delay: 400.ms),
                                const SizedBox(height: 16),

                                // Password field
                                Text(
                                  'Password',
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Enter password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            obscurePassword = !obscurePassword,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ).animate().fadeIn(delay: 500.ms),
                                const SizedBox(height: 32),

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: FilledButton(
                                    onPressed: isLoading
                                        ? null
                                        : _handleAdminLogin,
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ).animate().fadeIn(delay: 600.ms),
                                const SizedBox(height: 16),

                                // Demo credentials hint
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Demo Credentials',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Username: admin | Password: admin123',
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Username: manager | Password: manager123',
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 700.ms),
                              ],
                            ),
                          ),
                        ),
                      ).animate().slideY(delay: 800.ms, duration: 500.ms),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
