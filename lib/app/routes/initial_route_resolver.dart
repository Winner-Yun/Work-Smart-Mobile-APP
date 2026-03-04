import 'package:flutter/foundation.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';

class InitialRouteResolver {
  static Future<String> resolve() async {
    if (kIsWeb) {
      return AppAdminRoute.authAdminScreen;
    }

    final dbHelper = DatabaseHelper();
    final tutorialSeen = await dbHelper.getConfig('tutorial_seen') == 'true';
    final cachedLogin = await dbHelper.getCachedLogin();

    return !tutorialSeen
        ? AppRoute.tutorial
        : (cachedLogin != null ? AppRoute.appmain : AppRoute.authScreen);
  }
}
