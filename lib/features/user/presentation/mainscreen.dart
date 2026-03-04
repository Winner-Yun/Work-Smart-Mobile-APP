import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/activity_screens/activity_feed_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/attendence_screens/attendance_stats_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/attendence_screens/leave_attendance_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/homepagescreen.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/profile&setting_screens/profile_screens.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;
  final int initialIndex;

  const MainScreen({super.key, this.loginData, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // ──────────────── EMPLOYEE APP NAVIGATION ────────────────
  // Renders main tabs: Home, Attendance, Leave Requests, Profile
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isActivityTab = _currentIndex == 3;

    final List<Widget> screens = [
      HomePageScreen(
        loginData: widget.loginData,
        onProfileTap: () {
          setState(() {
            _currentIndex = 4;
          });
        },
      ),
      AttendanceStatsScreen(loginData: widget.loginData),
      LeaveAttendanceScreen(loginData: widget.loginData),
      ActivityFeedScreen(loginData: widget.loginData),
      ProfileScreen(loginData: widget.loginData),
    ];

    Widget scaffoldBody = Scaffold(
      appBar: isActivityTab ? _buildActivityAppBar(context) : null,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardTheme.color,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_filled),
              label: AppStrings.tr('home_menu'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.how_to_reg),
              label: AppStrings.tr('atd_menu'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.beach_access),
              label: AppStrings.tr('leave_menu'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.timeline_rounded),
              label: AppStrings.tr('activity_menu'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppStrings.tr('profile_menu'),
            ),
          ],
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: scaffoldBody,
    );
  }

  PreferredSizeWidget _buildActivityAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      title: Text(
        AppStrings.tr('live_activity_title'),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoute.telegramConfig,
            arguments: widget.loginData,
          ),
          icon: Icon(
            Icons.send_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoute.notificationScreen,
            arguments: widget.loginData,
          ),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).iconTheme.color,
                ),
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
