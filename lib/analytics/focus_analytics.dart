import '../model/models.dart';

/// Actual recorded focus time for one local calendar day.
class DailyFocus {
  const DailyFocus(this.date, this.seconds);

  final DateTime date;
  final int seconds;
  double get minutes => seconds / 60;
}

class GentleStreak {
  const GentleStreak({
    required this.currentDays,
    required this.bestDays,
    required this.graceDayUsed,
  });

  final int currentDays;
  final int bestDays;
  final bool graceDayUsed;
}

// Normalise calendar dates to UTC midnight so DST cannot distort day counts.
DateTime _day(DateTime instant) {
  final local = instant.toLocal();
  return DateTime.utc(local.year, local.month, local.day);
}

bool _qualifies(Session session) =>
    session.endTime != null && (session.actualSeconds ?? 0) > 0;

/// Includes both completed and early-ended sessions with positive recorded time.
/// Ignores open sessions and sessions with no recorded focus time.
/// Output always covers Monday through Sunday of the reference date's week.
List<DailyFocus> weeklyFocusTotals(
  Iterable<Session> sessions,
  DateTime referenceDate,
) {
  final today = _day(referenceDate);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final totals = List<int>.filled(7, 0);

  for (final session in sessions) {
    if (!_qualifies(session)) {
      continue;
    }
    final index = _day(session.startTime).difference(monday).inDays;
    if (index >= 0 && index < totals.length) {
      totals[index] += session.actualSeconds!;
    }
  }
  return List<DailyFocus>.generate(
    7,
    (index) => DailyFocus(monday.add(Duration(days: index)), totals[index]),
    growable: false,
  );
}

/// One focus date = one streak day, regardless of the number of sessions.
/// One missed calendar day may be bridged within a streak. A second gap starts
/// a fresh streak. This is gentle feedback, never a productivity grade.
GentleStreak calculateGentleStreak(
  Iterable<Session> sessions,
  DateTime referenceDate,
) {
  final today = _day(referenceDate);
  final days = <DateTime>{
    for (final session in sessions)
      if (_qualifies(session) && !_day(session.startTime).isAfter(today))
        _day(session.startTime),
  }.toList()..sort();

  if (days.isEmpty) {
    return const GentleStreak(currentDays: 0, bestDays: 0, graceDayUsed: false);
  }

  var run = 0;
  var best = 0;
  var graceUsed = false;
  DateTime? previous;

  for (final day in days) {
    final gap = previous == null ? 1 : day.difference(previous).inDays;
    if (gap > 2 || (gap == 2 && graceUsed)) {
      run = 1;
      graceUsed = false;
    } else {
      run++;
      if (gap == 2) {
        graceUsed = true;
      }
    }
    if (run > best) {
      best = run;
    }
    previous = day;
  }

  final daysSinceLast = today.difference(days.last).inDays;
  final active = daysSinceLast <= 1 || (daysSinceLast == 2 && !graceUsed);
  return GentleStreak(
    currentDays: active ? run : 0,
    bestDays: best,
    graceDayUsed: graceUsed || (active && daysSinceLast == 2),
  );
}

String readableFocusTime(int seconds) {
  if (seconds <= 0) {
    return '0 min';
  }
  if (seconds < 60) {
    return '$seconds sec';
  }
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return remaining == 0 ? '$minutes min' : '$minutes min $remaining sec';
}
