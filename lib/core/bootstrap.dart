import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/initial_route_resolver.dart';
import 'package:flutter_worksmart_mobile_app/config/env.dart';
import 'package:flutter_worksmart_mobile_app/config/firebase_options.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/live_data_bootstrap.dart';

class AppBootstrap {
  static Future<String> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Init environment variables
    await dotenv.load(fileName: '.env');
    Env.googleMapsApiKey;

    // Init Firebase and database
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
      await LiveDataBootstrap.initialize();
    } catch (_) {}

    FlutterError.onError = (details) =>
        FlutterError.dumpErrorToConsole(details);

    // Load preferences
    await ThemeManager().loadSettings();
    await LanguageManager().loadSettings();

    return await InitialRouteResolver.resolve();
  }
}
