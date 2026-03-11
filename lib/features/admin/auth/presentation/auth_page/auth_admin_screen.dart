import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/auth/logic/auth_admin_logic.dart';

class AuthAdminScreen extends StatefulWidget {
  const AuthAdminScreen({super.key});

  @override
  State<AuthAdminScreen> createState() => _AuthAdminScreenState();
}

class _AuthAdminScreenState extends State<AuthAdminScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AuthAdminLogic _authLogic;
  late final AnimationController _fadeController;
  late final AnimationController _bgMotionController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _bgPanXAnimation;
  late final Animation<double> _bgPanYAnimation;

  final Color _bgColor = AppColors.darkBg;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    _bgMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    final bgMotionCurve = CurvedAnimation(
      parent: _bgMotionController,
      curve: Curves.easeInOutSine,
    );
    _bgPanXAnimation = Tween<double>(
      begin: -16,
      end: 16,
    ).animate(bgMotionCurve);
    _bgPanYAnimation = Tween<double>(
      begin: 12,
      end: -12,
    ).animate(bgMotionCurve);

    _fadeController.forward();
    _bgMotionController.repeat(reverse: true);

    _authLogic = AuthAdminLogic(
      context: context,
      usernameController: _usernameController,
      passwordController: _passwordController,
      formKey: _formKey,
    );
    _authLogic.seedDatabase();
    _checkCachedLogin();
  }

  void _checkCachedLogin() {
    _authLogic.checkCachedLogin((username, userType) {
      _authLogic.autoLoginNavigation(username, userType);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bgMotionController.dispose();
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
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppAdminRoute.adminDashboard,
          (route) => false,
        );
        _authLogic.clearForm();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageManager(),
      builder: (context, _) {
        final isMobile = MediaQuery.of(context).size.width < 800;
        final languageManager = LanguageManager();
        final isKhmer = languageManager.locale == 'km';
        final currentLanguageText = isKhmer ? 'Khmer (KM)' : 'English (EN)';

        return Scaffold(
          backgroundColor: _bgColor,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Decorative auth background image layer.
                Positioned(
                  top: -26,
                  left: -26,
                  right: -26,
                  bottom: -26,
                  child: AnimatedBuilder(
                    animation: _bgMotionController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _bgPanXAnimation.value,
                          _bgPanYAnimation.value,
                        ),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      AppImg.authBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _bgColor.withOpacity(0.35),
                          _bgColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -120,
                  left: -80,
                  child: _buildDecorCircle(
                    size: 280,
                    color: AppColors.tertiary.withOpacity(0.16),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  right: -90,
                  child: _buildDecorCircle(
                    size: 320,
                    color: AppColors.secondary.withOpacity(0.14),
                  ),
                ),
                SlideTransition(
                  position: _slideAnimation,
                  child: isMobile
                      ? _buildMobileLayout()
                      : _buildDesktopLayout(),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.language, color: Colors.white70),
                      tooltip: 'Current language: $currentLanguageText',
                      onPressed: () {
                        languageManager.changeLanguage(isKhmer ? 'en' : 'km');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecorCircle({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: _buildRightFormSide(isMobile: true),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: _buildRightFormSide(isMobile: true),
        ),
      ),
    );
  }

  Widget _buildLeftBrandSide({
    bool isLeftAligned = false,
    bool isCompact = false,
  }) {
    final logoSize = isCompact ? 44.0 : 60.0;
    final brandTextSize = isCompact ? 24.0 : 28.0;
    final rowSpacing = isCompact ? 12.0 : 16.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isLeftAligned
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: isLeftAligned
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Image.asset(AppImg.appIconLight, height: logoSize, width: logoSize),
            SizedBox(width: rowSpacing),
            Text(
              'WorkSmart',
              style: TextStyle(
                color: Colors.white,
                fontSize: brandTextSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightFormSide({bool isMobile = false}) {
    final formContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildLeftBrandSide(isCompact: true, isLeftAligned: true),
            ),
            const SizedBox(height: 26),
            Text(
              AppStrings.tr('welcome'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr('login_subtitle_admin').toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),
            _buildTextField(
              controller: _usernameController,
              hint: AppStrings.tr('username').toUpperCase(),
              validator: _authLogic.validateUsername,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              hint: AppStrings.tr('password').toUpperCase(),
              isPassword: true,
              validator: _authLogic.validatePassword,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  disabledBackgroundColor: AppColors.tertiary,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppStrings.tr('login').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: formContent,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: formContent,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.black38,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}
