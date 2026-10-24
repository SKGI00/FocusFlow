import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/model/models.dart';
import 'package:focusflow/settings/focus_settings.dart';

class MemorySettingsKeysStore implements SettingsKeysStore {
  final Map<String, Object> data = {};

  @override
  Future<int?> getInt(String key) async => data[key] as int?;

  @override
  Future<bool?> getBool(String key) async => data[key] as bool?;

  @override
  Future<String?> getString(String key) async => data[key] as String?;

  @override
  Future<void> setInt(String key, int value) async {
    data[key] = value;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    data[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    data[key] = value;
  }
}

Session completedFocusOn(DateTime date) => Session(
  startTime: DateTime(date.year, date.month, date.day, 10),
  endTime: DateTime(date.year, date.month, date.day, 10, 5),
  plannedMinutes: 15,
  actualSeconds: 300,
  completed: false,
);

void main() {
  test('S1: defaults are 30 minutes and no reminder', () async {
    final saved = await FocusSettingsRepository(
      store: MemorySettingsKeysStore(),
    ).load();
    expect(saved.defaultMinutes, 30);
    expect(saved.reminderEnabled, false);
    expect(saved.reminderMinuteOfDay, 19 * 60);
  });

  test('S2: settings survive a fresh repository instance', () async {
    final store = MemorySettingsKeysStore();
    await FocusSettingsRepository(store: store).save(
      const FocusSettings(
        defaultMinutes: 3,
        reminderEnabled: true,
        reminderMinuteOfDay: 7 * 60 + 15,
      ),
    );
    final loaded = await FocusSettingsRepository(store: store).load();
    expect(loaded.defaultMinutes, 3);
    expect(loaded.reminderEnabled, true);
    expect(loaded.reminderMinuteOfDay, 435);
  });

  test('S3: 120 minutes allowed; 2 and 121 rejected', () {
    const prefs = FocusSettings();
    expect(prefs.copyWith(defaultMinutes: 120).defaultMinutes, 120);
    expect(() => prefs.copyWith(defaultMinutes: 2), throwsRangeError);
    expect(() => prefs.copyWith(defaultMinutes: 121), throwsRangeError);
  });

  test('S4: invalid stored values recover to defaults', () async {
    final store = MemorySettingsKeysStore();
    store.data['focusflow.default_duration'] = 900;
    store.data['focusflow.reminder_minute'] = -5;
    final loaded = await FocusSettingsRepository(store: store).load();
    expect(loaded.defaultMinutes, 30);
    expect(loaded.reminderMinuteOfDay, 1140);
  });

  test('S5: disabled or too-early reminder never appears', () {
    final now = DateTime(2026, 10, 25, 20);
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(),
        now: now,
        sessions: [],
      ),
      false,
    );
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(reminderEnabled: true),
        now: DateTime(2026, 10, 25, 18, 59),
        sessions: [],
      ),
      false,
    );
  });

  test('S6: user may be prompted only after chosen time', () {
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(reminderEnabled: true),
        now: DateTime(2026, 10, 25, 19),
        sessions: [],
      ),
      true,
    );
  });

  test('S7: no reminder after an actual session today', () {
    final today = DateTime(2026, 10, 25, 20);
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(reminderEnabled: true),
        now: today,
        sessions: [completedFocusOn(today)],
      ),
      false,
    );
  });

  test('S8: dismissing a reminder lasts through the same day', () async {
    final repo = FocusSettingsRepository(store: MemorySettingsKeysStore());
    final now = DateTime(2026, 10, 25, 21);
    await repo.dismissForToday(now);
    expect(await repo.dismissedOn(), '2026-10-25');
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(reminderEnabled: true),
        now: now,
        sessions: [],
        dismissedOn: await repo.dismissedOn(),
      ),
      false,
    );
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(reminderEnabled: true),
        now: DateTime(2026, 10, 26, 21),
        sessions: [],
        dismissedOn: await repo.dismissedOn(),
      ),
      true,
    );
  });

  test('S9: an unfinished session is not treated as completed focus', () {
    final now = DateTime(2026, 10, 25, 21);
    expect(
      shouldOfferInAppReminder(
        settings: const FocusSettings(reminderEnabled: true),
        now: now,
        sessions: [Session(startTime: now, plannedMinutes: 15)],
      ),
      true,
    );
  });
}
