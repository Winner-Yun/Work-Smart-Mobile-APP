// For web: conditional import of dart:html
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/app/theme/theme.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/user/restartwidget.dart';

void _updateWebTitle(String title) {
  if (kIsWeb) {
    try {
      html.document.title = title;
    } catch (e) {
      // Fallback - title update failed
    }
  }
}

class _PageTitleObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRouteTitle(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _updateRouteTitle(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _updateRouteTitle(previousRoute);
    }
  }

  void _updateRouteTitle(Route<dynamic> route) {
    final settings = route.settings;
    String title = 'WorkSmart';

    // Admin routes
    if (settings.name == AppAdminRoute.adminDashboard) {
      title = 'Dashboard | WorkSmart';
    } else if (settings.name == AppAdminRoute.authAdminScreen) {
      title = 'Admin Login | WorkSmart';
    } else if (settings.name == AppAdminRoute.staffManagement) {
      title = 'Staff Management | WorkSmart';
    } else if (settings.name == AppAdminRoute.geofencing) {
      title = 'Geofencing | WorkSmart';
    } else if (settings.name == AppAdminRoute.performanceLeaderboard) {
      title = 'Performance Leaderboard | WorkSmart';
    } else if (settings.name == AppAdminRoute.leaveRequests) {
      title = 'Leave Requests | WorkSmart';
    } else if (settings.name == AppAdminRoute.analyticsReports) {
      title = 'Analytics Reports | WorkSmart';
    } else if (settings.name == AppAdminRoute.systemSettings) {
      title = 'System Settings | WorkSmart';
    } else if (settings.name == AppAdminRoute.adminTutorial) {
      title = 'Tutorial | WorkSmart';
    }
    // User routes
    else if (settings.name == AppRoute.authScreen) {
      title = 'Login | WorkSmart';
    } else if (settings.name == AppRoute.appmain) {
      title = 'Home | WorkSmart';
    } else if (settings.name == AppRoute.tutorial) {
      title = 'Tutorial | WorkSmart';
    } else if (settings.name == AppRoute.leaderboardScreen) {
      title = 'Leaderboard | WorkSmart';
    } else if (settings.name == AppRoute.achievementScreen) {
      title = 'Achievements | WorkSmart';
    } else if (settings.name == AppRoute.settingScreen) {
      title = 'Settings | WorkSmart';
    }

    _updateWebTitle(title);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  await ThemeManager().loadSettings();
  await LanguageManager().loadSettings();

  String initialRoute;

  if (kIsWeb) {
    initialRoute = AppAdminRoute.adminTutorial;
  } else {
    final dbHelper = DatabaseHelper();

    final tutorialSeen = await dbHelper.getConfig('tutorial_seen') == 'true';

    final cachedLogin = await dbHelper.getCachedLogin();

    initialRoute = !tutorialSeen
        ? AppRoute.tutorial
        : (cachedLogin != null ? AppRoute.appmain : AppRoute.authScreen);
  }

  runApp(RestartWidget(child: MainApp(initialRoute: initialRoute)));
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeManager(), LanguageManager()]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WorkSmart',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeManager().themeMode,
          initialRoute: initialRoute,
          routes: AppRoute.routes,
          navigatorObservers: [_PageTitleObserver()],
        );
      },
    );
  }
}
