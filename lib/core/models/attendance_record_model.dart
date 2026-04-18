/// Represents a single attendance record returned by
///   GET  /teachers/sessions/{session_id}/attendance
///   POST /teachers/sessions/{session_id}/attendance
class AttendanceRecordModel {
  final String id;
  final String sessionId;
  final String studentId;

  /// Backend may return the student name directly (convenient for display).
  final String? studentName;

  /// ISO 8601 datetime string when attendance was recorded.
  final String? markedAt;

  /// How the record was created: "manual" (teacher tap) | "face" (recognition).
  final String? method;

  final bool isPresent;
  final String? notes;

  const AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    this.studentName,
    this.markedAt,
    this.method,
    this.isPresent = true,
    this.notes,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString(),
      markedAt: json['marked_at']?.toString(),
      method: json['method']?.toString(),
      isPresent: json['is_present'] != false, // default true
      notes: json['notes']?.toString(),
    );
  }

  /// Parses [markedAt] to a [DateTime] (returns null if unparseable / missing).
  DateTime? get markedAtDateTime {
    if (markedAt == null) return null;
    try {
      return DateTime.parse(markedAt!);
    } catch (_) {
      return null;
    }
  }
}
