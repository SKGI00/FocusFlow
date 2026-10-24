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
    presenter.selectFeeling(3);
    presenter.toggleTag('Mobile');
    expect(presenter.rating, 3);
    expect(presenter.tags, contains('Mobile'));

    presenter.selectFeeling(3);
    presenter.toggleTag('Mobile');
    expect(presenter.rating, isNull);
    expect(presenter.tags, isEmpty);
  });

  test('R4: four readable focus ratings preserve original SQLite values', () {
    expect(ReflectionPresenter.feelingLabels, [
      'Difficult',
      'Okay',
      'Good',
      'Choice 🤙',
    ]);
    expect(ReflectionPresenter.feelingRatings, [1, 3, 4, 5]);
    expect(ReflectionPresenter.feelingEmoji, ['😓', '🙂', '😊', '🤙']);
    expect(ReflectionPresenter.labelForRating(2), 'Tricky (earlier option)');
    presenter.selectFeeling(2); // Historical value is not a new UI option.
    expect(presenter.rating, isNull);
    presenter.selectFeeling(5);
    expect(presenter.rating, 5);
    expect(ReflectionPresenter.labelForRating(presenter.rating), 'Choice 🤙');
  });

  test('R5: support tags match the redesigned reflection', () {
    expect(ReflectionPresenter.supportTags, [
      'Quiet space',
      'Music',
      'Mobile',
      'Quick break',
      'Tired',
      'Noise',
    ]);
    presenter.toggleTag('Quick break');
    presenter.toggleTag('Noise');
    expect(presenter.tags, containsAll(['Quick break', 'Noise']));
  });

  test('R6: NZ Choice option saves and appears in history mapping', () async {
    presenter.selectFeeling(5);
    presenter.toggleTag('Quiet space');
    expect(await presenter.save(), true);
    final saved = await reflections.forSession(sessionId);
    expect(saved?.rating, 5);
    expect(ReflectionPresenter.labelForRating(saved?.rating), 'Choice 🤙');
  });
}
