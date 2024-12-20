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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DraftUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        notification_preferences INTEGER,
        profile_picture TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS DraftEvents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      category INTEGER,
      price REAL,
      status INTEGER,
      event_id TEXT,
      imagePath TEXT
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

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

      await db.execute(''' 
      CREATE TABLE DraftUsers_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        notification_preferences INTEGER,
        profile_picture TEXT
      )
    ''');
      await db.execute(''' 
      CREATE TABLE DraftEvents_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
      CREATE TABLE DraftGifts_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        category INTEGER,
        price REAL,
        status INTEGER,
        event_id TEXT,
        imagePath TEXT
      )
    ''');

      await db.execute(''' 
      INSERT INTO DraftUsers_new (id, name, email, notification_preferences, profile_picture)
      SELECT id, name, email, notification_preferences, profile_picture FROM DraftUsers
    ''');
      await db.execute(''' 
      INSERT INTO DraftEvents_new (id, name, date, location, description, status, category, user_id)
      SELECT id, name, date, location, description, status, category, user_id FROM DraftEvents
    ''');
      await db.execute(''' 
      INSERT INTO DraftGifts_new (id, name, description, category, price, status, event_id, imagePath)
      SELECT id, name, description, category, price, status, event_id, imagePath FROM DraftGifts
    ''');

      await db.execute('''DROP TABLE IF EXISTS DraftUsers''');
      await db.execute('''DROP TABLE IF EXISTS DraftEvents''');
      await db.execute('''DROP TABLE IF EXISTS DraftGifts''');

      await db.execute('''ALTER TABLE DraftUsers_new RENAME TO DraftUsers''');
      await db.execute('''ALTER TABLE DraftEvents_new RENAME TO DraftEvents''');
      await db.execute('''ALTER TABLE DraftGifts_new RENAME TO DraftGifts''');
    }
  }
}