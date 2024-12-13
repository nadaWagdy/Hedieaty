import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'drafts.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DraftUsers (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        notification_preferences INTEGER,
        profile_picture TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DraftEvents (
        id TEXT PRIMARY KEY,
        name TEXT,
        date TEXT,
        location TEXT,
        description TEXT,
        status INTEGER,
        category INTEGER,
        user_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DraftGifts (
      id TEXT PRIMARY KEY,
      name TEXT,
      description TEXT,
      category INTEGER,
      price REAL,
      status INTEGER,
      event_id TEXT
    )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DraftFriends (
        user_id TEXT,
        friend_id TEXT,
        PRIMARY KEY (user_id, friend_id)
      )
    ''');
  }

  Future<void> updateUser(User user) async {
    final db = await openDatabase('drafts.db');
    await db.update(
      'DraftUsers',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}