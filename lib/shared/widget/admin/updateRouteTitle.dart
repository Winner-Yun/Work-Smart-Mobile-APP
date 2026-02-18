import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';

class UpdateRouteTitle {
  static void _updateWebTitle(String title) {
    if (kIsWeb) {
      try {
        html.document.title = title;
      } catch (e) {
        debugPrint('Failed to update web title: $e');
      }
    }
  }

  static void updateRouteTitle(Route<dynamic> route) {
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

class PageTitleObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    UpdateRouteTitle.updateRouteTitle(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      UpdateRouteTitle.updateRouteTitle(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      UpdateRouteTitle.updateRouteTitle(previousRoute);
    }
  }
}
