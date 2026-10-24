import 'dart:async';

import 'package:flutter/foundation.dart';

enum SessionStatus { ready, running, paused, completed }

class SessionPresenter extends ChangeNotifier {
  SessionPresenter({int initialMinutes = 25})
    : assert(initialMinutes > 0),
      _durationMinutes = initialMinutes,
      _remaining = Duration(minutes: initialMinutes);

  int _durationMinutes;
  Duration _remaining;
  SessionStatus _status = SessionStatus.ready;

  DateTime? _endTime;
  Timer? _ticker;

  int get durationMinutes => _durationMinutes;
  Duration get remaining => _remaining;
  SessionStatus get status => _status;

  String get formattedTime {
    final totalSeconds = (_remaining.inMilliseconds / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void setDuration(int minutes) {
    if (minutes <= 0 || _status != SessionStatus.ready) {
      return;
    }

    _durationMinutes = minutes;
    _remaining = Duration(minutes: minutes);
    notifyListeners();
  }

  void start() {
    if (_status != SessionStatus.ready) return;

    _startCountdown();
  }

  void pause() {
    if (_status != SessionStatus.running) return;

    _updateRemaining();
    if (_status != SessionStatus.running) return;

    _ticker?.cancel();
    _ticker = null;

    _status = SessionStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (_status != SessionStatus.paused) return;

    _startCountdown();
  }

  void complete() {
    if (_status != SessionStatus.running && _status != SessionStatus.paused) {
      return;
    }

    _ticker?.cancel();
    _ticker = null;

    _status = SessionStatus.completed;
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _endTime = null;

    _remaining = Duration(minutes: _durationMinutes);
    _status = SessionStatus.ready;

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
      _ticker?.cancel();
      _ticker = null;
      _status = SessionStatus.completed;
    } else {
      _remaining = updated;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
