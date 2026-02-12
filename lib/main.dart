<<<<<<< HEAD
// import 'package:flutter/material.dart';
// import 'package:flutter_worksmart_mobile_app/app/theme/theme.dart';
// import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';

// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'WorkSmart',
//       theme: AppThemes.lightTheme,
//       darkTheme: AppThemes.darkTheme,
//       themeMode: ThemeMode.system,

//       initialRoute: AppRoute.tutorial,
//       routes: AppRoute.routes,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/theme/theme.dart';
import 'package:flutter_worksmart_mobile_app/routes/Screens/WorkAreaSetup.dart';
=======
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/app/theme/theme.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/restartwidget.dart';
>>>>>>> 8f57aa06023bbf0bc95db6e5b814d79fa9786560

/// Main App Entry Point
/// Initializes themes, language, and routes based on platform/login status
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager().loadSettings();
  await LanguageManager().loadSettings();
  final dbHelper = DatabaseHelper();
  final tutorialSeen = await dbHelper.getConfig('tutorial_seen') == 'true';
  final cachedLogin = await dbHelper.getCachedLogin();

  // ──────────────── PLATFORM-BASED ROUTING ────────────────
  // Web → Admin login | Mobile → Tutorial or Employee login
  final initialRoute = kIsWeb
      ? AppRoute
            .adminLoginWeb // Web: Admin login required
      : (!tutorialSeen
            ? AppRoute
                  .tutorial // Mobile: Tutorial first
            : (cachedLogin != null
                  ? AppRoute.appmain
                  : AppRoute.authScreen)); // Mobile: Employee login

  runApp(RestartWidget(child: MainApp(initialRoute: initialRoute)));
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkSmart',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home:Workareasetup(),
=======
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
        );
      },
>>>>>>> 8f57aa06023bbf0bc95db6e5b814d79fa9786560
    );
  }
}

