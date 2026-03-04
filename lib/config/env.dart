import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get authApiKey => dotenv.env['AUTH_API_KEY'] ?? '';
}
