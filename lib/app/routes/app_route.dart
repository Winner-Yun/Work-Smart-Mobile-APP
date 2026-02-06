import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/features/auth/presentation/authscreen.dart';
import 'package:flutter_worksmart_mobile_app/features/auth/presentation/forgot_pas_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/auth/presentation/tutorail_screens/tutorial_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/admin/light_admin_homepage.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/achievement_screens/achievement_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/annual_leave_request_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/attendance_calendar_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/attendance_detail_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/achievement_screens/empleaderboard_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/homepage_screens/face_scan_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/profile&setting_screens/help_support_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/homepage_screens/leave_management_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/mainscreen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/homepage_screens/notification_screens.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/profile&setting_screens/setting_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/attendence_screens/sick_leave_request_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/profile&setting_screens/telegram_integration.dart';

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
  static const String attendanceScreen = '/attendance-screen';
  static const String sickleaveScreen = '/sickleaveScreen';
  static const String annualleaveScreen = '/annualleaveScreen-screen';
  static const String settingScreen = '/settingScreen';
  static const String telegramConfig = '/telegramConfig';
  static const String helpSupportScreen = '/helpSupportScreen';
  static const String ligt_admin_homepage= '/lightadminhomepage';


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
    sickleaveScreen: (context) => const SickLeaveRequestScreen(),
    annualleaveScreen: (context) => const AnnualLeaveRequestScreen(),
    settingScreen: (context) => const SettingsScreen(),
    telegramConfig: (context) => const TelegramIntegration(),
    helpSupportScreen: (context) => const HelpSupportScreen(),
    ligt_admin_homepage :(context) =>const LightAdminHomepage(),


  };
}
