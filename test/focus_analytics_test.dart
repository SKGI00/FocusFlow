import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/analytics/focus_analytics.dart';
import 'package:focusflow/model/models.dart';

Session focus(int year, int month, int day, int seconds) => Session(
  startTime: DateTime(year, month, day, 10),
  endTime: DateTime(year, month, day, 10, 20),
  plannedMinutes: 25,
  actualSeconds: seconds,
  completed: false,
);

void main() {
  test('A1: weekly totals are Monday through Sunday', () {
    final daily = weeklyFocusTotals([
      focus(2026, 10, 19, 60),
      focus(2026, 10, 20, 150),
      focus(2026, 10, 20, 30),
    ], DateTime(2026, 10, 25));

    expect(daily.length, 7);
    expect(daily[0].date.weekday, DateTime.monday);
    expect(daily.map((e) => e.seconds).toList(), [60, 180, 0, 0, 0, 0, 0]);
  });

  test('A2: ignore an open session and zero focus', () {
    final daily = weeklyFocusTotals([
      Session(startTime: DateTime(2026, 10, 20), plannedMinutes: 25),
      focus(2026, 10, 20, 0),
      focus(2026, 10, 20, 70),
    ], DateTime(2026, 10, 25));
    expect(daily[1].seconds, 70);
  });

  test('A3: exclude sessions outside the displayed week', () {
    final daily = weeklyFocusTotals([
      focus(2026, 10, 18, 300),
      focus(2026, 10, 26, 500),
      focus(2026, 10, 25, 90),
    ], DateTime(2026, 10, 25));
    expect(daily.map((e) => e.seconds).toList(), [0, 0, 0, 0, 0, 0, 90]);
  });

  test('A4: consecutive focus dates count once each', () {
    final streak = calculateGentleStreak([
      focus(2026, 10, 23, 180),
      focus(2026, 10, 24, 60),
      focus(2026, 10, 24, 120),
      focus(2026, 10, 25, 40),
    ], DateTime(2026, 10, 25));
    expect(streak.currentDays, 3);
    expect(streak.bestDays, 3);
    expect(streak.graceDayUsed, false);
  });

  test('A5: one missed day can be bridged', () {
    final streak = calculateGentleStreak([
      focus(2026, 10, 21, 40),
      focus(2026, 10, 23, 50),
      focus(2026, 10, 24, 60),
    ], DateTime(2026, 10, 25));
    expect(streak.currentDays, 3);
    expect(streak.bestDays, 3);
    expect(streak.graceDayUsed, true);
  });

  test('A6: a second missed day starts a new run', () {
    final streak = calculateGentleStreak([
      focus(2026, 10, 21, 40),
      focus(2026, 10, 23, 50),
      focus(2026, 10, 25, 60),
    ], DateTime(2026, 10, 25));
    expect(streak.currentDays, 1);
    expect(streak.bestDays, 2);
  });

  test('A7: inactive current run retains historical best', () {
    final streak = calculateGentleStreak([
      focus(2026, 10, 19, 60),
      focus(2026, 10, 20, 70),
    ], DateTime(2026, 10, 25));
    expect(streak.currentDays, 0);
    expect(streak.bestDays, 2);
  });

  test('A8: empty history and readable duration', () {
    final streak = calculateGentleStreak([], DateTime(2026, 10, 25));
    expect(streak.currentDays, 0);
    expect(streak.bestDays, 0);
    expect(readableFocusTime(0), '0 min');
    expect(readableFocusTime(18), '18 sec');
    expect(readableFocusTime(125), '2 min 5 sec');
  });
}
