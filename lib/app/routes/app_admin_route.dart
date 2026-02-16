import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/auth/presentation/auth_page/auth_admin_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/auth/presentation/toturail_page/admin_tutorial_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/presentation/geofencing_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/presentation/homepage_dashboard_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/presentation/manage_users_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/presentation/mange_leaveemp_dashboard_screen.dart';

class AppAdminRoute {
  static const String adminTutorial = '/admin-tutorial';
  static const String authAdminScreen = '/admin-auth';
  static const String adminDashboard = '/admin-dashboard';
  static const String staffManagement = '/admin-staff-management';
  static const String geofencing = '/admin-geofencing';
  static const String performanceLeaderboard = '/admin-performance-leaderboard';
  static const String leaveRequests = '/admin-leave-requests';
  static const String analyticsReports = '/admin-analytics-reports';
  static const String systemSettings = '/admin-system-settings';

  // ──────────────── ADMIN ROUTE DEFINITIONS ────────────────
  static Map<String, WidgetBuilder> routes = {
    adminTutorial: (context) => const AdminTutorialScreen(),
    authAdminScreen: (context) => const AuthAdminScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    staffManagement: (context) => const ManageUsersScreen(),
    geofencing: (context) => const GeofencingScreen(),
    performanceLeaderboard: (context) =>
        const AdminDashboardScreen(), // Placeholder
    leaveRequests: (context) =>
        const MangeLeaveEmpDashboardScreen(), // Placeholder
    analyticsReports: (context) => const AdminDashboardScreen(), // Placeholder
    systemSettings: (context) => const AdminDashboardScreen(), // Placeholder
  };
}
