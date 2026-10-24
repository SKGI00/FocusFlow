import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../model/models.dart';

class ReflectionPresenter extends ChangeNotifier {
  ReflectionPresenter({
    required this.sessionId,
    required ReflectionRepository repository,
    DateTime Function()? clock,
  }) : // Keep the public `repository:` argument while storing it privately.
       // ignore: prefer_initializing_formals
       _repository = repository,
       _clock = clock ?? DateTime.now;

  final int sessionId;
  final ReflectionRepository _repository;
  final DateTime Function() _clock;

  static const List<String> feelingLabels = [
    'Hard',
    'Tricky',
    'Okay',
    'Good',
    'Great',
  ];
  static const List<String> supportTags = [
    'Quiet space',
    'Music',
    'Phone away',
    'Short break',
    'Tired',
  ];

  final Set<String> _tags = {};
  int? _rating;
  String _note = '';
  bool _saving = false;
  String? _error;

  int? get rating => _rating;
  Set<String> get tags => Set.unmodifiable(_tags);
  bool get isSaving => _saving;
  String? get error => _error;

  void selectFeeling(int value) {
    if (value < 1 || value > 5 || _saving) return;
    _rating = _rating == value ? null : value;
    _error = null;
    notifyListeners();
  }

  void toggleTag(String value) {
    if (_saving || !supportTags.contains(value)) return;
    if (!_tags.remove(value)) _tags.add(value);
    _error = null;
    notifyListeners();
  }

  void setNote(String value) {
    if (_saving) return;
    _note = value;
    _error = null;
  }

  Future<bool> save() async {
    if (_saving) return false;
    final note = _note.trim();
    if (_rating == null && _tags.isEmpty && note.isEmpty) {
      _error = 'Choose a feeling, tag or note, or tap Skip.';
      notifyListeners();
      return false;
    }

    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.insert(
        Reflection(
          sessionId: sessionId,
          timestamp: _clock(),
          rating: _rating,
          tags: _tags.isEmpty ? null : (_tags.toList()..sort()).join(','),
          note: note.isEmpty ? null : note,
        ),
      );
      _saving = false;
      notifyListeners();
      return true;
    } catch (_) {
      _saving = false;
      _error = 'Could not save your reflection. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
