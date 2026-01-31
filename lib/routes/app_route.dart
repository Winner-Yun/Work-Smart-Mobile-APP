import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/auth/authscreen.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_screen.dart';
import 'package:flutter_worksmart_mobile_app/screen/achievement_screen.dart';
import 'package:flutter_worksmart_mobile_app/screen/attendance_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/attendance_detail_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/mainscreen.dart';

class AppRoute {
  static const String tutorial = '/tutorial';
  static const String authScreen = '/auth';
  static const String appmain = '/appmain';
  static const String attendanceDetail = '/attendance-detail';
  static const String attendance_screen = '/attendance-screen';
  static const String achievement_screen= '/achievement_screen';

  static Map<String, WidgetBuilder> routes = {
    tutorial: (context) => const TutorialScreen(),
    authScreen: (context) => const Authscreen(),
    appmain: (context) => const MainScreen(),
    attendanceDetail: (context) => const AttendanceDetailScreen(),
    attendance_screen :(context)=> const AttendanceScreen(),
    achievement_screen :(context)=> const AchievementScreen(),


  };
}
