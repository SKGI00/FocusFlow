import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/notifications/reminder_scheduler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  test('N1: next reminder today if the chosen time is later', () {
    final auckland = tz.getLocation('Pacific/Auckland');
    final now = tz.TZDateTime(auckland, 2026, 10, 25, 8, 30);
    final next = nextDailyNotificationTime(now, 19 * 60);
    expect(next.year, 2026);
    expect(next.month, 10);
    expect(next.day, 25);
    expect(next.hour, 19);
    expect(next.minute, 0);
  });

  test('N2: schedule moves to next day when time has passed', () {
    final auckland = tz.getLocation('Pacific/Auckland');
    final now = tz.TZDateTime(auckland, 2026, 10, 25, 22);
    final next = nextDailyNotificationTime(now, 19 * 60);
    expect(next.day, 26);
    expect(next.hour, 19);
  });

  test('N3: 00:00 allowed; invalid minutes rejected', () {
    final utc = tz.getLocation('Etc/UTC');
    final now = tz.TZDateTime(utc, 2026, 10, 25, 8);
    expect(nextDailyNotificationTime(now, 0).hour, 0);
    expect(() => nextDailyNotificationTime(now, -1), throwsRangeError);
    expect(() => nextDailyNotificationTime(now, 1440), throwsRangeError);
  });
}
