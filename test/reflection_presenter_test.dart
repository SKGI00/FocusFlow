import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:focusflow/data/database_helper.dart';
import 'package:focusflow/data/repositories.dart';
import 'package:focusflow/model/models.dart';
import 'package:focusflow/presenter/reflection_presenter.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper helper;
  late ReflectionRepository reflections;
  late ReflectionPresenter presenter;
  late int sessionId;

  setUp(() async {
    helper = DatabaseHelper(path: inMemoryDatabasePath);
    reflections = ReflectionRepository(helper);
    sessionId = await SessionRepository(
      helper,
    ).insert(Session(startTime: DateTime(2026, 10, 25, 9), plannedMinutes: 25));
    presenter = ReflectionPresenter(
      sessionId: sessionId,
      repository: reflections,
    );
  });

  tearDown(() async {
    presenter.dispose();
    await helper.close();
  });

  test('R1: an empty reflection is not saved', () async {
    expect(await presenter.save(), false);
    expect(presenter.error, isNotNull);
    expect(await reflections.forSession(sessionId), isNull);
  });

  test('R2: rating, tags and note persist in SQLite', () async {
    presenter.selectFeeling(4);
    presenter.toggleTag('Music');
    presenter.setNote('I kept coming back to the task.');

    expect(await presenter.save(), true);

    final saved = await reflections.forSession(sessionId);
    expect(saved, isNotNull);
    expect(saved!.rating, 4);
    expect(saved.tags, 'Music');
    expect(saved.note, 'I kept coming back to the task.');
  });

  test('R3: selected feeling and tag can be removed', () {
    presenter.selectFeeling(2);
    presenter.toggleTag('Phone away');
    expect(presenter.rating, 2);
    expect(presenter.tags, contains('Phone away'));

    presenter.selectFeeling(2);
    presenter.toggleTag('Phone away');
    expect(presenter.rating, isNull);
    expect(presenter.tags, isEmpty);
  });
}
