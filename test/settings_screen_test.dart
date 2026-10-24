import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/settings/focus_settings.dart';
import 'package:focusflow/notifications/reminder_scheduler.dart';
import 'package:focusflow/view/settings_screen.dart';

class _MemoryKeys implements SettingsKeysStore {
  final Map<String, Object> values = {};
  @override
  Future<int?> getInt(String key) async => values[key] as int?;
  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;
  @override
  Future<String?> getString(String key) async => values[key] as String?;
  @override
  Future<void> setInt(String key, int value) async {
    values[key] = value;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

class _FakeScheduler implements ReminderScheduler {
  bool permissionGranted = true;
  final List<int> scheduled = [];
  int cancellations = 0;
  int testNotifications = 0;
  bool pending = false;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleDaily(int minuteOfDay) async {
    scheduled.add(minuteOfDay);
    pending = true;
  }

  @override
  Future<void> cancel() async {
    cancellations++;
    pending = false;
  }

  @override
  Future<bool> isScheduled() async => pending;

  @override
  Future<void> sendTestNotification() async {
    testNotifications++;
  }
}

void main() {
  testWidgets('S10: Settings can save a different default duration', (
    tester,
  ) async {
    final repo = FocusSettingsRepository(store: _MemoryKeys());
    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Default focus time'), findsOneWidget);
    await tester.tap(find.text('15 min'));
    await tester.pumpAndSettle();
    expect((await repo.load()).defaultMinutes, 15);
  });

  testWidgets('S11: reminder toggle is opt-in and persistent', (tester) async {
    final repo = FocusSettingsRepository(store: _MemoryKeys());
    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    expect((await repo.load()).reminderEnabled, false);
    await tester.tap(find.text('Remind me to focus'));
    await tester.pumpAndSettle();
    expect((await repo.load()).reminderEnabled, true);
    expect(find.text('Reminder time'), findsOneWidget);
  });

  testWidgets('S12: Enabling schedules the OS reminder', (tester) async {
    final repo = FocusSettingsRepository(store: _MemoryKeys());
    final scheduler = _FakeScheduler();
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(repository: repo, scheduler: scheduler),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remind me to focus'));
    await tester.pumpAndSettle();
    expect(scheduler.scheduled, [19 * 60]);
    expect((await repo.load()).reminderEnabled, true);
  });

  testWidgets('S13: Permission denied leaves notifications disabled', (
    tester,
  ) async {
    final repo = FocusSettingsRepository(store: _MemoryKeys());
    final scheduler = _FakeScheduler()..permissionGranted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(repository: repo, scheduler: scheduler),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remind me to focus'));
    await tester.pumpAndSettle();
    expect(scheduler.scheduled, isEmpty);
    expect((await repo.load()).reminderEnabled, false);
  });

  testWidgets('S14: Turning reminders off cancels the notification', (
    tester,
  ) async {
    final repo = FocusSettingsRepository(store: _MemoryKeys());
    final scheduler = _FakeScheduler();
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(repository: repo, scheduler: scheduler),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remind me to focus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remind me to focus'));
    await tester.pumpAndSettle();
    expect(scheduler.cancellations, 1);
    expect((await repo.load()).reminderEnabled, false);
  });
  testWidgets('S15: test notification requires opt-in and can be sent', (
    tester,
  ) async {
    final repo = FocusSettingsRepository(store: _MemoryKeys());
    final scheduler = _FakeScheduler();
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(repository: repo, scheduler: scheduler),
      ),
    );
    await tester.pumpAndSettle();

    // No test-notification action before consent.
    expect(find.text('Send test notification'), findsNothing);
    expect(scheduler.testNotifications, 0);

    // Enabling reminders saves consent and schedules the daily alarm.
    await tester.tap(find.text('Remind me to focus'));
    await tester.pumpAndSettle();
    expect((await repo.load()).reminderEnabled, isTrue);
    expect(scheduler.scheduled, [19 * 60]);

    // This control is below the fold on the default 800x600 test surface.
    // Actually scroll the ListView before tapping it. ensureVisible by itself
    // did not make the Text hit-testable in the earlier regression test.
    final sendButton = find.text('Send test notification');
    await tester.scrollUntilVisible(
      sendButton,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(sendButton.hitTestable(), findsOneWidget);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(scheduler.testNotifications, 1);
    expect(scheduler.pending, isTrue);

    // Scroll back to the switch; disable reminders and verify cancellation.
    final toggle = find.text('Remind me to focus');
    await tester.scrollUntilVisible(
      toggle,
      -160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(toggle.hitTestable(), findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect((await repo.load()).reminderEnabled, isFalse);
    expect(scheduler.cancellations, 1);
    expect(find.text('Send test notification'), findsNothing);
  });

  testWidgets('S16: missing daily alarm can be scheduled again', (
    tester,
  ) async {
    final store = _MemoryKeys();
    final repo = FocusSettingsRepository(store: store);
    await repo.save(const FocusSettings(reminderEnabled: true));
    final scheduler = _FakeScheduler();
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(repository: repo, scheduler: scheduler),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Schedule reminder'), findsOneWidget);
    await tester.ensureVisible(find.text('Schedule reminder'));
    await tester.tap(find.text('Schedule reminder'));
    await tester.pumpAndSettle();
    expect(scheduler.scheduled, [19 * 60]);
    expect(find.text('Daily reminder scheduled'), findsOneWidget);
  });
}
