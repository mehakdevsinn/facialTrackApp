import 'package:facialtrackapp/core/models/session_model.dart';

/// Represents a single attendance record returned by
///   GET  /teachers/sessions/{session_id}/attendance
///   POST /teachers/sessions/{session_id}/attendance
///   POST /teachers/sessions/{session_id}/attendance/leave
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

  /// Present — server clears on_leave when true.
  final bool isPresent;

  /// Excused leave: is_present false, on_leave true, leave_reason set.
  final bool onLeave;

  final String? leaveReason;
  final String? notes;

  const AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    this.studentName,
    this.markedAt,
    this.method,
    this.isPresent = true,
    this.onLeave = false,
    this.leaveReason,
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
      isPresent: json['is_present'] == true,
      onLeave: json['on_leave'] == true || json['is_on_leave'] == true,
      leaveReason: json['leave_reason']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  /// Parses [markedAt] as a UTC instant (naive strings = UTC wall from API).
  DateTime? get markedAtDateTime =>
      parseTeacherSessionInstantToUtc(markedAt);
}
