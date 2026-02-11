import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/attendance_stats_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/homepage_screens/homepagescreen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/leave_attendance_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/profile&setting_screens/profile_screens.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePageScreen(),
    const AttendanceStatsScreen(),
    const LeaveAttendanceScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: _screens[_currentIndex],
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
            selectedItemColor: AppColors.primary,
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
                icon: const Icon(Icons.person),
                label: AppStrings.tr('profile_menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
