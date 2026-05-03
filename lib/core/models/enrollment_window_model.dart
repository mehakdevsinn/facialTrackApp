import 'package:facialtrackapp/core/utils/student_report_datetime.dart';

/// Model for GET /api/v1/students/face/enrollment-window
class EnrollmentWindowModel {
  /// The only field the app needs for routing.
  /// true  → show Face Enrollment screen
  /// false → go to Student Dashboard
  final bool enrollmentOpen;

  /// Admin-set deadline (YYYY-MM-DD), or null if not set.
  final String? deadline;

  /// true when the student has already uploaded all 3 angles.
  final bool studentEnrolled;

  const EnrollmentWindowModel({
    required this.enrollmentOpen,
    required this.studentEnrolled,
    this.deadline,
  });

  factory EnrollmentWindowModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentWindowModel(
      enrollmentOpen: json['enrollment_open'] as bool? ?? false,
      studentEnrolled: json['student_enrolled'] as bool? ?? false,
      deadline: json['deadline'] as String?,
    );
  }
}

/// Model for GET/PUT /api/v1/admin/settings/enrollment-deadline
class EnrollmentDeadlineModel {
  /// YYYY-MM-DD string, or null if no deadline is set.
  final String? enrollmentDeadline;

  const EnrollmentDeadlineModel({this.enrollmentDeadline});

  factory EnrollmentDeadlineModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentDeadlineModel(
      enrollmentDeadline: json['enrollment_deadline'] as String?,
    );
  }

  /// Parses the deadline string into a UTC-based instant, or returns null.
  DateTime? get deadlineDate =>
      parseReportToUtcInstant(enrollmentDeadline);
}

/// Model for GET/PUT /api/v1/admin/settings/attendance-criteria
class AttendanceCriteriaModel {
  final int attendanceThresholdPercent;
  final String? updatedAt;
  final String? updatedBy;

  const AttendanceCriteriaModel({
    required this.attendanceThresholdPercent,
    this.updatedAt,
    this.updatedBy,
  });

  factory AttendanceCriteriaModel.fromJson(Map<String, dynamic> json) {
    final raw = json['attendance_threshold_percent'];
    final parsed = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    return AttendanceCriteriaModel(
      attendanceThresholdPercent: (parsed ?? 75).clamp(50, 100),
      updatedAt: json['updated_at'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }
}
