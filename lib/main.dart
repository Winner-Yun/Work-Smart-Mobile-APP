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

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkSmart',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home:Workareasetup(),
    );
  }
}

