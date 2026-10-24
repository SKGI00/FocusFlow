class Session {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedMinutes;
  final int? actualSeconds;
  final bool completed;
  final String? goal;

  const Session({
    this.id,
    required this.startTime,
    this.endTime,
    required this.plannedMinutes,
    this.actualSeconds,
    this.completed = false,
    this.goal,
  }) : assert(plannedMinutes > 0);

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'start_time': startTime.toUtc().toIso8601String(),
    'end_time': endTime?.toUtc().toIso8601String(),
    'planned_minutes': plannedMinutes,
    'actual_seconds': actualSeconds,
    'completed': completed ? 1 : 0,
    'goal': goal,
  };

  factory Session.fromMap(Map<String, Object?> map) => Session(
    id: map['id'] as int?,
    startTime: DateTime.parse(map['start_time'] as String).toLocal(),
    endTime: map['end_time'] == null
        ? null
        : DateTime.parse(map['end_time'] as String).toLocal(),
    plannedMinutes: map['planned_minutes'] as int,
    actualSeconds: map['actual_seconds'] as int?,
    completed: (map['completed'] as int) == 1,
    goal: map['goal'] as String?,
  );
}

class DistractionEvent {
  final int? id;
  final int sessionId;
  final DateTime timestamp;
  final String? tag;
  final String? note;

  const DistractionEvent({
    this.id,
    required this.sessionId,
    required this.timestamp,
    this.tag,
    this.note,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'session_id': sessionId,
    'ts': timestamp.toUtc().toIso8601String(),
    'tag': tag,
    'note': note,
  };

  factory DistractionEvent.fromMap(Map<String, Object?> map) =>
      DistractionEvent(
        id: map['id'] as int?,
        sessionId: map['session_id'] as int,
        timestamp: DateTime.parse(map['ts'] as String).toLocal(),
        tag: map['tag'] as String?,
        note: map['note'] as String?,
      );
}

class Reflection {
  final int? id;
  final int sessionId;
  final DateTime timestamp;
  final String? note;
  final String? tags;
  final int? rating;

  const Reflection({
    this.id,
    required this.sessionId,
    required this.timestamp,
    this.note,
    this.tags,
    this.rating,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'session_id': sessionId,
    'ts': timestamp.toUtc().toIso8601String(),
    'note': note,
    'tags': tags,
    'rating': rating,
  };

  factory Reflection.fromMap(Map<String, Object?> map) => Reflection(
    id: map['id'] as int?,
    sessionId: map['session_id'] as int,
    timestamp: DateTime.parse(map['ts'] as String).toLocal(),
    note: map['note'] as String?,
    tags: map['tags'] as String?,
    rating: map['rating'] as int?,
  );
}
