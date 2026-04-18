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

  /// Parses [startTime] to a [DateTime] (returns null if unparseable).
  DateTime? get startDateTime {
    try {
      return DateTime.parse(startTime);
    } catch (_) {
      return null;
    }
  }
}
