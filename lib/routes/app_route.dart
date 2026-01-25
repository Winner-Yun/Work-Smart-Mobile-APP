import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/auth/authscreen.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_screen.dart';

class AppRoute {
  static const String tutorial = '/tutorial';
  static const String authScreen = '/auth';

  static Map<String, WidgetBuilder> routes = {
    tutorial: (context) => const TutorialScreen(),
    authScreen: (context) => const Authscreen(),
  };
}
