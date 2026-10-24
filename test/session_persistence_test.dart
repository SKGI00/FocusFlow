import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:focusflow/data/database_helper.dart';
import 'package:focusflow/data/repositories.dart';
import 'package:focusflow/presenter/session_presenter.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper helper;
  late SessionRepository sessions;
  late DistractionRepository distractions;
  late SessionPresenter presenter;

  setUp(() {
    helper = DatabaseHelper(path: inMemoryDatabasePath);
    sessions = SessionRepository(helper);
    distractions = DistractionRepository(helper);

    presenter = SessionPresenter(
      sessions: sessions,
      distractions: distractions,
    );
  });

  tearDown(() async {
    await presenter.waitForWrites();
    presenter.dispose();
    await helper.close();
  });

  test('I1: starting a session creates a SQLite record', () async {
    presenter.start();
    await presenter.waitForWrites();

    final records = await sessions.all();

    expect(records.length, 1);
    expect(records.first.plannedMinutes, 25);
  });

  test('I2: distraction is saved against the session', () async {
    presenter.start();
    presenter.logDistraction('Phone');

    await presenter.waitForWrites();

    final id = await presenter.savedSessionId();

    expect(id, isNotNull);
    expect(await distractions.countForSession(id!), 1);
    expect(presenter.distractionCount, 1);

    final records = await distractions.forSession(id);
    expect(records.first.tag, 'Phone');
  });

  test('I3: ending early saves the session result', () async {
    presenter.start();
    presenter.complete();

    await presenter.waitForWrites();

    final records = await sessions.all();
    final saved = records.single;

    expect(saved.endTime, isNotNull);
    expect(saved.actualSeconds, isNotNull);
    expect(saved.actualSeconds, greaterThanOrEqualTo(0));
    expect(saved.completed, false);
    expect(presenter.endedEarly, true);
  });
}
