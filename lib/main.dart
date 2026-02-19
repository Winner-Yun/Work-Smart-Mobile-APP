import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/app/theme/theme.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/updateRouteTitle.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/splash/splash_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/user/restartwidget.dart';

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
          home: SplashScreen(nextRoute: initialRoute),
          routes: AppRoute.routes,
          navigatorObservers: [PageTitleObserver()],
        );
      },
    );
  }
}
