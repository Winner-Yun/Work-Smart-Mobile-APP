import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/auth/authscreen.dart';
import 'package:flutter_worksmart_mobile_app/auth/forgot_pas_screen.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/achievement_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/attendance_calendar_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/attendance_detail_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/empleaderboard_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/face_scan_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/leave_management_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/mainscreen.dart';
import 'package:flutter_worksmart_mobile_app/screens/notification_screens.dart';

class AppRoute {
  static const String tutorial = '/tutorial';
  static const String authScreen = '/auth';
  static const String appmain = '/appmain';
  static const String attendanceDetail = '/attendance-detail';
  static const String leaderboardScreen = '/leaderboardScreen';
  static const String achievementScreen = '/achievementScreen';
  static const String attendanCalendarScreen = '/callenderScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String forgotpassScreen = '/forgotpassScreen';
  static const String leaveDatailScreen = '/leaveDetailScreen';
  static const String faceScanScreen = '/faceScanScreen';

  static Map<String, WidgetBuilder> routes = {
    tutorial: (context) => const TutorialScreen(),
    authScreen: (context) => const Authscreen(),
    appmain: (context) => const MainScreen(),
    attendanceDetail: (context) => const AttendanceDetailScreen(),
    leaderboardScreen: (context) => const LeaderboardScreen(),
    achievementScreen: (context) => const AchievementScreen(),
    attendanCalendarScreen: (context) => const AttendanceCalendarScreen(),
    notificationScreen: (context) => const NotificationScreen(),
    forgotpassScreen: (context) => const ForgotPasswordScreen(),
    leaveDatailScreen: (context) => const LeaveDetailScreen(),
    faceScanScreen: (context) => const FaceScanScreen(),
  };
}
