import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  final _formKey = GlobalKey<FormState>(); // For Employee
  final _adminFormKey = GlobalKey<FormState>(); // For Admin
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final PageController _pageController = PageController();
  bool isEmployee = true;
  bool obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleTab(bool employee) {
    setState(() => isEmployee = employee);
    _pageController.animateToPage(
      employee ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleLogin() {
    final currentKey = isEmployee ? _formKey : _adminFormKey;

    if (currentKey.currentState != null &&
        currentKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEmployee
                ? AppStrings.tr('logging_in_employee')
                : AppStrings.tr('logging_in_admin'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoute.appmain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImg.authBackground),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Center(
                              child: Hero(
                                tag: 'logo',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(AppImg.appIcon, width: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "WorkSmart",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 70),
                          Column(
                            key: ValueKey<bool>(isEmployee),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEmployee
                                    ? AppStrings.tr('smart_hr_system')
                                    : AppStrings.tr('admin_dashboard'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isEmployee
                                    ? AppStrings.tr('welcome')
                                    : AppStrings.tr('admin_login_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -30 + ((1.0 - value) * 100)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildTabToggle(),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 450,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: _buildLoginForm(true),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: _buildLoginForm(false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton(AppStrings.tr('employee_tab'), true),
          _tabButton(AppStrings.tr('admin_tab'), false),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool employee) {
    bool active = isEmployee == employee;
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleTab(employee),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool forEmployee) {
    return Form(
      key: forEmployee ? _formKey : _adminFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  forEmployee
                      ? AppStrings.tr('smart_hr_management')
                      : AppStrings.tr('advanced_access'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: forEmployee ? AppColors.primary : Colors.red[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  forEmployee
                      ? AppStrings.tr('login_subtitle_employee')
                      : AppStrings.tr('login_subtitle_admin'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            forEmployee
                ? AppStrings.tr('username_or_id')
                : AppStrings.tr('admin_id'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: AppColors.primary,
                selectionHandleColor: AppColors.primary,
                selectionColor: (AppColors.primary).withValues(alpha: 0.2),
              ),
            ),
            child: TextFormField(
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.tr('enter_id_error');
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: AppStrings.tr('enter_id_hint'),
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  forEmployee
                      ? Icons.person_outline
                      : Icons.admin_panel_settings_outlined,
                  color: AppColors.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr('password'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: AppColors.primary,
                selectionHandleColor: AppColors.primary,
                selectionColor: (AppColors.primary).withValues(alpha: 0.2),
              ),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.tr('enter_password_error');
                }
                if (value.length < 6) {
                  return AppStrings.tr('password_length_error');
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: AppStrings.tr('enter_password_hint'),
                hintStyle: TextStyle(color: Colors.grey[400]),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textGrey,
                  ),
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          SizedBox(height: forEmployee ? 10 : 0),

          if (forEmployee)
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoute.forgotpassScreen);
                },
                child: Text(
                  AppStrings.tr('forgot_password'),
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),

          SizedBox(height: forEmployee ? 10 : 34),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _handleLogin,
              child: Text(
                forEmployee
                    ? AppStrings.tr('login_button')
                    : AppStrings.tr('admin_login_button'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
