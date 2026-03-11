import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';

class InitialRouteResolver {
  static Future<String> resolve() async {
    await _waitForAuthStateRestore();

    final dbHelper = DatabaseHelper();
    final cachedLogin = await dbHelper.getCachedLogin();
    final hasFirebaseAdminSession = FirebaseAuth.instance.currentUser != null;

    if (kIsWeb) {
      if (hasFirebaseAdminSession) {
        return AppAdminRoute.adminDashboard;
      }
      return AppAdminRoute.authAdminScreen;
    }

    final tutorialSeen = await dbHelper.getConfig('tutorial_seen') == 'true';

    if (!tutorialSeen) {
      return AppRoute.tutorial;
    }

    if (hasFirebaseAdminSession) {
      return AppAdminRoute.adminDashboard;
    }

    if (cachedLogin == null) {
      return AppRoute.authScreen;
    }

    return _resolveAuthenticatedRoute(cachedLogin);
  }

  static Future<void> _waitForAuthStateRestore() async {
    try {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      // Ignore timeout/errors and fall back to current available auth state.
    }
  }

  static String _resolveAuthenticatedRoute(Map<String, dynamic> cachedLogin) {
    final userType = cachedLogin['user_type']?.toString().toLowerCase();
    if (userType == 'admin') {
      return kIsWeb ? AppAdminRoute.authAdminScreen : AppRoute.authScreen;
    }
    return AppRoute.appmain;
  }
}
