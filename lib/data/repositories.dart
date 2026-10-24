import 'package:sqflite/sqflite.dart';

import '../model/models.dart';
import 'database_helper.dart';

// Saves and retrieves focus sessions.
class SessionRepository {
  SessionRepository(this._helper);

  final DatabaseHelper _helper;

  Future<int> insert(Session session) async {
    final db = await _helper.database;
    return db.insert('sessions', session.toMap());
  }

  Future<void> update(Session session) async {
    if (session.id == null) {
      throw ArgumentError('Cannot update a session without an ID.');
    }

    final db = await _helper.database;
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<Session?> findById(int id) async {
    final db = await _helper.database;
    final rows = await db.query('sessions', where: 'id = ?', whereArgs: [id]);

    return rows.isEmpty ? null : Session.fromMap(rows.first);
  }

  Future<List<Session>> all() async {
    final db = await _helper.database;
    final rows = await db.query('sessions', orderBy: 'start_time DESC');

    return rows.map(Session.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
}

// Saves distractions and counts them for each session.
class DistractionRepository {
  DistractionRepository(this._helper);

  final DatabaseHelper _helper;

  Future<int> insert(DistractionEvent distraction) async {
    final db = await _helper.database;
    return db.insert('distractions', distraction.toMap());
  }

  Future<int> countForSession(int sessionId) async {
    final db = await _helper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM distractions WHERE session_id = ?',
      [sessionId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<DistractionEvent>> forSession(int sessionId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'distractions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'ts ASC',
    );

    return rows.map(DistractionEvent.fromMap).toList();
  }
}

// Saves and retrieves post-session reflections.
class ReflectionRepository {
  ReflectionRepository(this._helper);

  final DatabaseHelper _helper;

  Future<int> insert(Reflection reflection) async {
    final db = await _helper.database;
    return db.insert('reflections', reflection.toMap());
  }

  Future<Reflection?> forSession(int sessionId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'reflections',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    return rows.isEmpty ? null : Reflection.fromMap(rows.first);
  }
}
