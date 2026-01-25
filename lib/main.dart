import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/routes/app_route.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tutorial App',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansKhmerTextTheme(),
        primaryColor: const Color(0xFF004C4C),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoute.authScreen,
      routes: AppRoute.routes,
    );
  }
}
