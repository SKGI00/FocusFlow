import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../model/models.dart';

enum SessionStatus { ready, running, paused, completed }

class SessionPresenter extends ChangeNotifier {
  SessionPresenter({
    int initialMinutes = 25,
    SessionRepository? sessions,
    DistractionRepository? distractions,
  }) : assert(initialMinutes > 0),
       _durationMinutes = initialMinutes,
       _remaining = Duration(minutes: initialMinutes),
       // ignore: prefer_initializing_formals
       _sessions = sessions,
       // ignore: prefer_initializing_formals
       _distractions = distractions;

  final SessionRepository? _sessions;
  final DistractionRepository? _distractions;

  int _durationMinutes;
  Duration _remaining;
  SessionStatus _status = SessionStatus.ready;

  Timer? _ticker;
  DateTime? _endTime;
  DateTime? _startedAt;
  DateTime? _runningSince;
  Duration _focusedTime = Duration.zero;

  Future<int?>? _sessionIdFuture;
  Future<void> _pendingWrites = Future<void>.value();

  int _generation = 0;
  int _distractionCount = 0;
  bool _endedEarly = false;
  bool _disposed = false;
  String? _saveError;

  int get durationMinutes => _durationMinutes;
  Duration get remaining => _remaining;
  SessionStatus get status => _status;
  int get distractionCount => _distractionCount;
  bool get endedEarly => _endedEarly;
  String? get saveError => _saveError;

  String get formattedTime {
    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    final minutesPart = seconds ~/ 60;
    final secondsPart = seconds % 60;

    return '${minutesPart.toString().padLeft(2, '0')}:'
        '${secondsPart.toString().padLeft(2, '0')}';
  }

  void setDuration(int minutes) {
    if (minutes <= 0 || _status != SessionStatus.ready) return;

    _durationMinutes = minutes;
    _remaining = Duration(minutes: minutes);
    notifyListeners();
  }

  void start() {
    if (_status != SessionStatus.ready) return;

    final now = DateTime.now();
    _startedAt = now;
    _runningSince = now;
    _focusedTime = Duration.zero;
    _endedEarly = false;
    _distractionCount = 0;
    _saveError = null;
    _generation++;

    final repository = _sessions;
    if (repository != null) {
      _sessionIdFuture = _createSession(
        repository,
        Session(startTime: now, plannedMinutes: _durationMinutes),
      );
    } else {
      _sessionIdFuture = null;
    }

    _startCountdown();
  }

  Future<int?> _createSession(
    SessionRepository repository,
    Session session,
  ) async {
    try {
      return await repository.insert(session);
    } catch (_) {
      _reportError('Could not save this session.');
      return null;
    }
  }

  void pause() {
    if (_status != SessionStatus.running) return;

    _updateRemaining();
    if (_status != SessionStatus.running) return;

    final now = DateTime.now();
    _focusedTime += now.difference(_runningSince!);
    _runningSince = null;

    _ticker?.cancel();
    _ticker = null;
    _endTime = null;
    _status = SessionStatus.paused;

    notifyListeners();
  }

  void resume() {
    if (_status != SessionStatus.paused) return;

    _runningSince = DateTime.now();
    _startCountdown();
  }

  void complete() {
    if (_status == SessionStatus.running) {
      _updateRemaining();
    }

    if (_status != SessionStatus.running && _status != SessionStatus.paused) {
      return;
    }

    _finishSession();
  }

  void _finishSession() {
    final now = DateTime.now();

    if (_runningSince != null) {
      _focusedTime += now.difference(_runningSince!);
      _runningSince = null;
    }

    _ticker?.cancel();
    _ticker = null;
    _endTime = null;

    _endedEarly = _remaining > Duration.zero;
    _status = SessionStatus.completed;

    final idFuture = _sessionIdFuture;
    final repository = _sessions;
    final startedAt = _startedAt;

    if (idFuture != null && repository != null && startedAt != null) {
      final actualSeconds = _focusedTime.inSeconds
          .clamp(0, _durationMinutes * 60)
          .toInt();

      _queueWrite(() async {
        final id = await idFuture;
        if (id == null) return;

        await repository.update(
          Session(
            id: id,
            startTime: startedAt,
            endTime: now,
            plannedMinutes: _durationMinutes,
            actualSeconds: actualSeconds,
            completed: !_endedEarly,
          ),
        );
      });
    }

    notifyListeners();
  }

  void logDistraction(String tag) {
    if (_status != SessionStatus.running && _status != SessionStatus.paused) {
      return;
    }

    final repository = _distractions;
    final idFuture = _sessionIdFuture;

    if (repository == null || idFuture == null) {
      _reportError('Distraction logging is unavailable.');
      return;
    }

    final generation = _generation;

    _queueWrite(() async {
      final id = await idFuture;
      if (id == null) return;

      await repository.insert(
        DistractionEvent(sessionId: id, timestamp: DateTime.now(), tag: tag),
      );

      if (!_disposed && generation == _generation) {
        _distractionCount++;
        notifyListeners();
      }
    });
  }

  void _queueWrite(Future<void> Function() operation) {
    _pendingWrites = _pendingWrites.then((_) => operation()).catchError((
      Object error,
    ) {
      _reportError('Could not save the latest change.');
    });
  }

  void _reportError(String message) {
    if (_disposed) return;
    _saveError = message;
    notifyListeners();
  }

  Future<void> waitForWrites() async {
    final creation = _sessionIdFuture;
    if (creation != null) await creation;
    await _pendingWrites;
  }

  Future<int?> savedSessionId() async {
    await waitForWrites();
    return _sessionIdFuture;
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _endTime = null;
    _startedAt = null;
    _runningSince = null;
    _focusedTime = Duration.zero;
    _sessionIdFuture = null;

    _generation++;
    _remaining = Duration(minutes: _durationMinutes);
    _status = SessionStatus.ready;
    _distractionCount = 0;
    _endedEarly = false;
    _saveError = null;

    notifyListeners();
  }

  void _startCountdown() {
    _endTime = DateTime.now().add(_remaining);
    _status = SessionStatus.running;

    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );

    notifyListeners();
  }

  void _updateRemaining() {
    if (_status != SessionStatus.running || _endTime == null) {
      return;
    }

    final updated = _endTime!.difference(DateTime.now());

    if (updated <= Duration.zero) {
      _remaining = Duration.zero;
      _finishSession();
    } else {
      _remaining = updated;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
