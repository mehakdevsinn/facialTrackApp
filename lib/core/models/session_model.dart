bool _teacherSessionApiStringHasTimeZone(String s) {
  final t = s.trim();
  if (t.endsWith('Z')) return true;
  return RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(t) ||
      RegExp(r'[+-]\d{4}$').hasMatch(t);
}

/// Parses session API datetimes to a UTC instant.
///
/// Strings with `Z` or `±hh:mm` use normal [DateTime.parse] semantics.
///
/// **Naive** ISO strings (no zone) are treated as **UTC** wall time. The app
/// sends UTC via `DateTime.toUtc().toIso8601String()`; some backends return the
/// same instant **without** `Z`. Parsing those as local (Dart default) skews
/// elapsed duration by the device offset (e.g. ~5h for Pakistan vs 08:xx UTC).
DateTime? parseTeacherSessionInstantToUtc(String? raw) {
  if (raw == null) return null;
  final s = raw.trim().replaceFirst(' ', 'T');
  if (s.isEmpty) return null;
  try {
    if (_teacherSessionApiStringHasTimeZone(s)) {
      return DateTime.parse(s).toUtc();
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
      return DateTime.parse('${s}T00:00:00Z').toUtc();
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(s)) {
      return DateTime.parse('${s}Z').toUtc();
    }
    return DateTime.parse(s).toUtc();
  } catch (_) {
    return null;
  }
}

/// Represents a teaching session returned by:
///   POST /teachers/sessions             (create)
///   POST /teachers/sessions/{id}/stop   (stop – returns same shape, is_active=false)
///   GET  /teachers/sessions/active      (list)
class SessionModel {
  final String id;
  final String courseId;
  final String teacherId;

  /// Date portion of the session (YYYY-MM-DD or ISO string).
  final String? sessionDate;

  /// ISO 8601 datetime string.
  final String startTime;

  /// ISO 8601 datetime string.
  final String endTime;

  final bool isActive;
  final String? notes;
  final String? createdAt;

  const SessionModel({
    required this.id,
    required this.courseId,
    required this.teacherId,
    this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.notes,
    this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      sessionDate: json['session_date']?.toString(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      isActive: json['is_active'] == true,
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  /// [startTime] as a UTC instant (see [parseTeacherSessionInstantToUtc]).
  DateTime? get startDateTime => parseTeacherSessionInstantToUtc(startTime);

  /// [created_at] as a UTC instant when the backend sends it.
  DateTime? get createdDateTime => parseTeacherSessionInstantToUtc(createdAt);

  /// Prefer [createdDateTime] for elapsed live time, else [startDateTime].
  DateTime? get elapsedBaselineUtc =>
      createdDateTime ?? startDateTime;
}
