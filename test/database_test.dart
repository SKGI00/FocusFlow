import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:focusflow/data/database_helper.dart';
import 'package:focusflow/data/repositories.dart';
import 'package:focusflow/model/models.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper helper;
  late SessionRepository sessions;
  late DistractionRepository distractions;
  late ReflectionRepository reflections;

  setUp(() {
    helper = DatabaseHelper(path: inMemoryDatabasePath);
    sessions = SessionRepository(helper);
    distractions = DistractionRepository(helper);
    reflections = ReflectionRepository(helper);
  });

  tearDown(() async {
    await helper.close();
  });

  Session sampleSession() {
    return Session(startTime: DateTime(2026, 10, 24, 9), plannedMinutes: 25);
  }

  test('T1: save and retrieve a focus session', () async {
    final id = await sessions.insert(sampleSession());
    final saved = await sessions.findById(id);

    expect(saved, isNotNull);
    expect(saved!.plannedMinutes, 25);
    expect(saved.completed, false);
  });

  test('T2: distractions belong to the correct session', () async {
    final sessionId = await sessions.insert(sampleSession());

    for (var i = 0; i < 3; i++) {
      await distractions.insert(
        DistractionEvent(
          sessionId: sessionId,
          timestamp: DateTime.now(),
          tag: 'Phone',
        ),
      );
    }

    expect(await distractions.countForSession(sessionId), 3);
  });

  test('T3: deleting a session removes its distractions', () async {
    final sessionId = await sessions.insert(sampleSession());

    await distractions.insert(
      DistractionEvent(sessionId: sessionId, timestamp: DateTime.now()),
    );

    await sessions.delete(sessionId);

    expect(await distractions.countForSession(sessionId), 0);
  });

  test('T4: only one reflection is allowed per session', () async {
    final sessionId = await sessions.insert(sampleSession());

    final reflection = Reflection(
      sessionId: sessionId,
      timestamp: DateTime.now(),
      note: 'Good focus session',
    );

    await reflections.insert(reflection);

    await expectLater(
      reflections.insert(reflection),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('T5: database rejects invalid session duration', () async {
    final db = await helper.database;

    await expectLater(
      db.insert('sessions', {
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'planned_minutes': -5,
        'completed': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });
}
