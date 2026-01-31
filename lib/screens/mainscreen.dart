import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/screens/attendance_stats_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/homepagescreen.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const HomePageScreen(),
    const AttendanceStatsScreen(),
    const Center(child: Text("Leave Screen")),
    const Center(child: Text("Profile Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
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
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: AppStrings.tr('home_menu'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.how_to_reg),
                label: AppStrings.tr('atd_menu'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.beach_access),
                label: AppStrings.tr('leave_menu'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: AppStrings.tr('profile_menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
