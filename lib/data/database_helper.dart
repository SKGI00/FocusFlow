import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper({this.path});

  // Tests can provide an in-memory database path.
  // The real app uses its own local database file.
  final String? path;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final databasePath =
        path ?? p.join(await getDatabasesPath(), 'focusflow.db');

    return openDatabase(
      databasePath,
      version: 1,

      // Enforce relationships between database tables.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // Create tables when the database is first installed.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time TEXT NOT NULL,
            end_time TEXT,
            planned_minutes INTEGER NOT NULL CHECK(planned_minutes > 0),
            actual_seconds INTEGER CHECK(
              actual_seconds IS NULL OR actual_seconds >= 0
            ),
            completed INTEGER NOT NULL DEFAULT 0
              CHECK(completed IN (0, 1)),
            goal TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE distractions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            ts TEXT NOT NULL,
            tag TEXT,
            note TEXT,
            FOREIGN KEY(session_id)
              REFERENCES sessions(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE reflections (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL UNIQUE,
            ts TEXT NOT NULL,
            note TEXT,
            tags TEXT,
            rating INTEGER CHECK(
              rating IS NULL OR rating BETWEEN 1 AND 5
            ),
            FOREIGN KEY(session_id)
              REFERENCES sessions(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE streaks (
            id INTEGER PRIMARY KEY CHECK(id = 1),
            current_streak INTEGER NOT NULL DEFAULT 0,
            best_streak INTEGER NOT NULL DEFAULT 0,
            last_session_date TEXT,
            grace_used INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          INSERT INTO streaks (
            id, current_streak, best_streak, grace_used
          ) VALUES (1, 0, 0, 0)
        ''');
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
