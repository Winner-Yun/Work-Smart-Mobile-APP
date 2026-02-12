import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
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
            user_id TEXT NOT NULL,
            cached_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE login_cache (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              password TEXT NOT NULL,
              user_type TEXT NOT NULL,
              user_id TEXT NOT NULL,
              cached_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        }
      },
    );
  }

  Future<void> saveConfig(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getConfig(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  // Save login credentials for auto-login
  Future<void> saveCachedLogin(
    String username,
    String password,
    String userId,
    String userType,
  ) async {
    final db = await database;
    // Clear previous cache and save new login
    await db.delete('login_cache');
    await db.insert('login_cache', {
      'username': username,
      'password': password,
      'user_id': userId,
      'user_type': userType,
    });
  }

  // Retrieve cached login credentials
  Future<Map<String, dynamic>?> getCachedLogin() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('login_cache');

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Clear cached login (on logout)
  Future<void> clearCachedLogin() async {
    final db = await database;
    await db.delete('login_cache');
  }
}
