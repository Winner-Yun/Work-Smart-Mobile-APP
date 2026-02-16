import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// =========================
  /// DATABASE (MOBILE ONLY)
  /// =========================
  Future<Database?> get database async {
    if (kIsWeb) return null; // Web does not use SQLite
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'worksmart_config.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE login_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            user_type TEXT NOT NULL,
            user_id TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// =========================
  /// SETTINGS
  /// =========================
  Future<void> saveConfig(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      final db = await database;
      await db!.insert('settings', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<String?> getConfig(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      final db = await database;
      final maps = await db!.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        return maps.first['value'] as String;
      }
      return null;
    }
  }

  /// =========================
  /// LOGIN CACHE
  /// =========================
  Future<void> saveCachedLogin(
    String username,
    String password,
    String userId,
    String userType,
  ) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setString('user_id', userId);
      await prefs.setString('user_type', userType);
    } else {
      final db = await database;
      await db!.delete('login_cache');
      await db.insert('login_cache', {
        'username': username,
        'password': password,
        'user_id': userId,
        'user_type': userType,
      });
    }
  }

  Future<Map<String, dynamic>?> getCachedLogin() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      final userId = prefs.getString('user_id');
      final userType = prefs.getString('user_type');

      if (username != null &&
          password != null &&
          userId != null &&
          userType != null) {
        return {
          'username': username,
          'password': password,
          'user_id': userId,
          'user_type': userType,
        };
      }
      return null;
    } else {
      final db = await database;
      final maps = await db!.query('login_cache');

      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    }
  }

  Future<void> clearCachedLogin() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.remove('user_id');
      await prefs.remove('user_type');
    } else {
      final db = await database;
      await db!.delete('login_cache');
    }
  }
}
