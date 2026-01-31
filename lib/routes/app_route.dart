import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/auth/authscreen.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/attendance_detail_screen.dart';
import 'package:flutter_worksmart_mobile_app/screens/mainscreen.dart';
import 'package:flutter_worksmart_mobile_app/screens/profile_done.dart';
import 'package:flutter_worksmart_mobile_app/screens/setting_of_sytem.dart';

class AppRoute {
  static const String tutorial = '/tutorial';
  static const String authScreen = '/auth';
  static const String appmain = '/appmain';
  static const String attendanceDetail = '/attendance-detail';
  static const String settingofsytem = '/settingofsytem';
  static const String profiledone = '/profile_done';

  static Map<String, WidgetBuilder> routes = {
    tutorial: (context) => const TutorialScreen(),
    authScreen: (context) => const Authscreen(),
    appmain: (context) => const MainScreen(),
    attendanceDetail: (context) => const AttendanceDetailScreen(),
    settingofsytem: (context) => const setting_of_sytem(),
    profiledone: (context) => const profile_done(),
  };
}
