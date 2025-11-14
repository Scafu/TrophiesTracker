import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'games.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games(
            appId INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            publisher TEXT,
            description TEXT,
            headerImage TEXT,
            libraryImage TEXT,
            addedAt INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE trophies(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gameAppId INTEGER,
            displayName TEXT,
            description TEXT,
            isAchieved INTEGER DEFAULT 0,
            coloredIcon TEXT,
            uncoloredIcon TEXT,
            achievedAt INTEGER,
            FOREIGN KEY(gameAppId) REFERENCES games(appId)
          )
        ''');

        await db.execute('''
          CREATE TABLE activity(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gameAppId INTEGER NOT NULL,
            trophyDisplayName TEXT,
            timestamp INTEGER,
            FOREIGN KEY(gameAppId) REFERENCES games(appId),
            FOREIGN KEY(gameAppId, trophyDisplayName) REFERENCES trophies(gameAppId, displayName)
          )
        ''');
      },
    );
  }

  Future<void> close() async => _db?.close();
}
