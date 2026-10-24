// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../model/models.dart';

class ReflectionPresenter extends ChangeNotifier {
  ReflectionPresenter({
    required this.sessionId,
    required ReflectionRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final int sessionId;
  final ReflectionRepository _repository;
  final DateTime Function() _clock;

  static const List<String> feelingLabels = [
    'Difficult',
    'Okay',
    'Good',
    'Choice 🤙',
  ];
  static const List<String> supportTags = [
    'Quiet space',
    'Music',
    'Mobile',
    'Quick break',
    'Tired',
    'Noise',
  ];

  // Keep the original SQLite rating scale (1–5), so existing data remains
  // readable. The redesigned interface only offers 1, 3, 4 and 5.
  static const List<int> feelingRatings = [1, 3, 4, 5];
  static const List<String> feelingEmoji = ['😓', '🙂', '😊', '🤙'];

  static String labelForRating(int? rating) {
    switch (rating) {
      case 1:
        return 'Difficult';
      case 2:
        return 'Tricky (earlier option)';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Choice 🤙';
      default:
        return 'Not rated';
    }
  }

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
    if (!feelingRatings.contains(value) || _saving) return;
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
      _error = 'Choose an option, add a note, or tap Skip.';
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
