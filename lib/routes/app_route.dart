import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/auth/authscreen.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_screen.dart';
import 'package:flutter_worksmart_mobile_app/screen/attendance_screen.dart';
import 'package:flutter_worksmart_mobile_app/screen/telegram_integration.dart';

class AppRoute {
  static const String tutorial = '/tutorial';
  static const String authScreen = '/auth';
  static const String telegram = '/telegram';
  static const String attendance= '/attendance';

  static Map<String, WidgetBuilder> routes = {
    tutorial: (context) => const TutorialScreen(),
    authScreen: (context) => const Authscreen(),
    telegram: (context) => const TelegramIntegration(),
    attendance:(context)=> const AttendanceScreen(),
  };
}
