import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final PageController _pageController = PageController();
  bool isEmployee = true;
  bool obscurePassword = true;

  // Admin credentials database only
  static const Map<String, String> adminUsers = {
    'admin': 'admin123',
    'manager': 'manager123',
  };

  @override
  void initState() {
    super.initState();
    // For web, default to admin login; for mobile, default to employee
    if (kIsWeb) {
      isEmployee = false;
      Future.microtask(() {
        if (mounted) {
          _pageController.jumpToPage(1);
        }
      });
    }
    _checkCachedLogin();
  }

  // Check for cached login and auto-login if credentials exist
  Future<void> _checkCachedLogin() async {
    final dbHelper = DatabaseHelper();
    final cachedLogin = await dbHelper.getCachedLogin();

    if (cachedLogin != null && mounted) {
      final username = cachedLogin['username'] as String;
      final userType = cachedLogin['user_type'] as String;
      final userId = cachedLogin['user_id'] as String;

      // Auto-login with cached credentials
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userType == 'employee'
                    ? AppStrings.tr('logging_in_employee')
                    : AppStrings.tr('logging_in_admin'),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 1),
            ),
          );

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
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
      });
    }
  }

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
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (currentKey.currentState != null &&
        currentKey.currentState!.validate()) {
      // Validate credentials
      bool credentialsValid = false;
      String? userId;
      String userType = isEmployee ? 'employee' : 'admin';

      if (isEmployee) {
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

        if (user.isNotEmpty) {
          credentialsValid = true;
          userId = user['uid'];
        }
      } else {
        // Check admin credentials
        if (adminUsers.containsKey(username) &&
            adminUsers[username] == password) {
          credentialsValid = true;
          userId = username;
        }
      }

      if (!credentialsValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr('invalid_credentials')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Success - navigate to main app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEmployee
                ? AppStrings.tr('logging_in_employee')
                : AppStrings.tr('logging_in_admin'),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Store user info and navigate
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Save login credentials to cache
          final dbHelper = DatabaseHelper();
          if (isEmployee) {
            dbHelper.saveCachedLogin(username, password, userId!, userType);
          }

          // Pass full user data to the app
          final loginData = {
            'uid': userId,
            'username': username,
            'userType': userType,
          };

          // Navigate to main app (admin dashboard will be added later)
          Navigator.pushReplacementNamed(
            context,
            AppRoute.appmain,
            arguments: loginData,
          );
          // Clear form
          _usernameController.clear();
          _passwordController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageManager(),
      builder: (context, child) {
        final theme = Theme.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: theme.cardTheme.color,
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

                      // --- Language Switcher ---
                      Positioned(
                        top: 50,
                        right: 20,
                        child: _buildLanguageButton(theme),
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
                                          Image.asset(
                                            AppImg.appIcon,
                                            width: 20,
                                          ),
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
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildTabToggle(theme),
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
                                    child: _buildLoginForm(true, theme),
                                  ),
                                  if (kIsWeb)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: _buildLoginForm(false, theme),
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
      },
    );
  }

  Widget _buildLanguageButton(ThemeData theme) {
    final languageManager = LanguageManager();
    final isKhmer = languageManager.locale == 'km';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final newLang = isKhmer ? 'en' : 'km';
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(),
              ),
            ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
          );

          await Future.delayed(const Duration(milliseconds: 800));

          if (context.mounted) {
            Navigator.of(context).pop();
            languageManager.changeLanguage(newLang);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                isKhmer ? "ភាសាខ្មែរ" : "English",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton(AppStrings.tr('employee_tab'), true, theme),
          if (kIsWeb) _tabButton(AppStrings.tr('admin_tab'), false, theme),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool employee, ThemeData theme) {
    bool active = isEmployee == employee;
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleTab(employee),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? theme.colorScheme.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool forEmployee, ThemeData theme) {
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
                    color: forEmployee
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  forEmployee
                      ? AppStrings.tr('login_subtitle_employee')
                      : AppStrings.tr('login_subtitle_admin'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            data: theme.copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: theme.colorScheme.primary,
                selectionHandleColor: theme.colorScheme.primary,
                selectionColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
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
                prefixIcon: Icon(
                  forEmployee
                      ? Icons.person_outline
                      : Icons.admin_panel_settings_outlined,
                  color: theme.colorScheme.primary,
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
            data: theme.copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: theme.colorScheme.primary,
                selectionHandleColor: theme.colorScheme.primary,
                selectionColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
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
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
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
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
          SizedBox(height: forEmployee ? 10 : 34),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _handleLogin,
              child: Text(
                forEmployee
                    ? AppStrings.tr('login_button')
                    : AppStrings.tr('admin_login_button'),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
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
