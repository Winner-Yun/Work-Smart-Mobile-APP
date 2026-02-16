import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // <-- ADDED: flutter_animate import
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/auth/logic/auth_admin_logic.dart';

class AuthAdminScreen extends StatefulWidget {
  const AuthAdminScreen({super.key});

  @override
  State<AuthAdminScreen> createState() => _AuthAdminScreenState();
}

class _AuthAdminScreenState extends State<AuthAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AuthAdminLogic _authLogic;

  @override
  void initState() {
    super.initState();
    _authLogic = AuthAdminLogic(
      context: context,
      usernameController: _usernameController,
      passwordController: _passwordController,
      formKey: _formKey,
    );
    _checkCachedLogin();
  }

  void _checkCachedLogin() {
    _authLogic.checkCachedLogin((username, userType) {
      _authLogic.autoLoginNavigation(username, userType);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final success = await _authLogic.handleLogin();
      if (success && mounted) {
        _authLogic.navigateToAdminPanel();
        _authLogic.clearForm();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child:
              Container(
                    clipBehavior: Clip.antiAlias,
                    constraints: const BoxConstraints(
                      maxWidth: 1000,
                      minHeight: 600,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // --- LEFT SIDE: THE FORM ---
                        Expanded(flex: 5, child: _buildFormSide(isMobile)),

                        // --- RIGHT SIDE: VISUAL PANEL ---
                        if (!isMobile)
                          Expanded(flex: 5, child: _buildVisualSide()),
                      ],
                    ),
                  )
                  // ANIMATION: Main Container Entrance (Scale & Fade)
                  .animate()
                  .fade(duration: 600.ms, curve: Curves.easeOut)
                  .scaleXY(
                    begin: 0.95,
                    end: 1.0,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
        ),
      ),
    );
  }

  Widget _buildFormSide(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 56,
        vertical: 40,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              [
                    // Brand Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "ADMIN PORTAL",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.tr('login'),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.tr('login_subtitle_admin'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Input Fields
                    _buildLabel("Username"),
                    _buildTextField(
                      controller: _usernameController,
                      hint: "Enter your username",
                      icon: Icons.alternate_email_rounded,
                      validator: _authLogic.validateUsername,
                    ),
                    const SizedBox(height: 24),
                    _buildLabel("Password"),
                    _buildTextField(
                      controller: _passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: _authLogic.validatePassword,
                    ),
                    const SizedBox(height: 40),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppStrings.tr('admin_login_title'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ]
                  .animate(interval: 50.ms, delay: 200.ms)
                  .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
        ),
      ),
    );
  }

  Widget _buildVisualSide() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.tertiary],
        ),
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 80,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 48),
                Text(
                      AppStrings.tr('admin_login_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 16),
                Text(
                      "Manage your workspace, users, and analytical data from one centralized secure hub.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(fontSize: 15, color: AppColors.primary),
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 22,
          color: AppColors.primary.withOpacity(0.6),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 22,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                color: AppColors.textGrey,
              )
            : null,
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textGrey.withOpacity(0.7),
          fontSize: 15,
        ),
        filled: true,
        fillColor: AppColors.textGrey.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.textGrey.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.textGrey.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 12, height: 1.2),
      ),
    );
  }
}
