import 'package:facialtrackapp/core/utils/student_report_datetime.dart';

String? _sanitizeApiName(String? raw) {
  if (raw == null) return null;
  final t = raw.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  return t.isEmpty ? null : t;
}

class StudentMonthPickerBounds {
  final String? monthPickerStart;
  final String? monthPickerEnd;
  final bool hasEnrolledCourses;
  final String timezone;

  const StudentMonthPickerBounds({
    required this.monthPickerStart,
    required this.monthPickerEnd,
    required this.hasEnrolledCourses,
    required this.timezone,
  });

  factory StudentMonthPickerBounds.fromJson(Map<String, dynamic> json) {
    return StudentMonthPickerBounds(
      monthPickerStart: json['month_picker_start']?.toString(),
      monthPickerEnd: json['month_picker_end']?.toString(),
      hasEnrolledCourses: json['has_enrolled_courses'] == true,
      timezone: json['timezone']?.toString() ?? 'Asia/Karachi',
    );
  }
}

class StudentCourseSummary {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String teacherName;
  final int totalSessions;
  final int sessionsAttended;
  final int sessionsAbsent;
  final double attendancePercentage;

  const StudentCourseSummary({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.teacherName,
    required this.totalSessions,
    required this.sessionsAttended,
    required this.sessionsAbsent,
    required this.attendancePercentage,
  });

  factory StudentCourseSummary.fromJson(Map<String, dynamic> json) {
    return StudentCourseSummary(
      courseId: json['course_id']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
      courseName: _sanitizeApiName(json['course_name']?.toString()) ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      sessionsAttended: (json['sessions_attended'] as num?)?.toInt() ?? 0,
      sessionsAbsent: (json['sessions_absent'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendance_percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StudentSubjectsResponse {
  final String studentId;
  final String studentName;
  final List<StudentCourseSummary> courses;

  const StudentSubjectsResponse({
    required this.studentId,
    required this.studentName,
    required this.courses,
  });

  factory StudentSubjectsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['courses'] as List<dynamic>? ?? [];
    return StudentSubjectsResponse(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      courses: list
          .map((e) =>
              StudentCourseSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentAttendanceSessionRecord {
  final String sessionId;
  /// Course UUID when API provides it (filters / grouping).
  final String? courseId;
  final DateTime? sessionDateUtc;
  /// Scheduled session start (class window).
  final DateTime? sessionStartTimeUtc;
  final String? courseName;
  final String? courseCode;
  final String? teacherName;
  final bool isPresent;
  /// When the student was marked present by the system.
  final DateTime? entryTimeUtc;
  final DateTime? exitTimeUtc;
  final String? verificationMethod;

  const StudentAttendanceSessionRecord({
    required this.sessionId,
    this.courseId,
    this.sessionDateUtc,
    this.sessionStartTimeUtc,
    this.courseName,
    this.courseCode,
    this.teacherName,
    required this.isPresent,
    this.entryTimeUtc,
    this.exitTimeUtc,
    this.verificationMethod,
  });

  factory StudentAttendanceSessionRecord.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSessionRecord(
      sessionId: json['session_id']?.toString() ?? '',
      courseId: json['course_id']?.toString(),
      sessionDateUtc: parseReportToUtcInstant(json['session_date']?.toString()),
      sessionStartTimeUtc: parseReportToUtcInstant(
        json['session_start_time']?.toString(),
      ),
      courseName: _sanitizeApiName(json['course_name']?.toString()),
      courseCode: json['course_code']?.toString(),
      teacherName: json['teacher_name']?.toString(),
      isPresent: json['is_present'] == true,
      entryTimeUtc: parseReportToUtcInstant(json['entry_time']?.toString()),
      exitTimeUtc: parseReportToUtcInstant(json['exit_time']?.toString()),
      verificationMethod: json['verification_method']?.toString(),
    );
  }
}

class StudentAttendanceHistoryResponse {
  final int year;
  final int month;
  final int totalSessions;
  final int sessionsAttended;
  final int sessionsAbsent;
  final List<StudentAttendanceSessionRecord> records;

  const StudentAttendanceHistoryResponse({
    required this.year,
    required this.month,
    required this.totalSessions,
    required this.sessionsAttended,
    required this.sessionsAbsent,
    required this.records,
  });

  factory StudentAttendanceHistoryResponse.fromJson(
      Map<String, dynamic> json) {
    final list = json['records'] as List<dynamic>? ?? [];
    return StudentAttendanceHistoryResponse(
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      sessionsAttended: (json['sessions_attended'] as num?)?.toInt() ?? 0,
      sessionsAbsent: (json['sessions_absent'] as num?)?.toInt() ?? 0,
      records: list
          .map((e) => StudentAttendanceSessionRecord.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentSubjectDetailResponse {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String teacherName;
  final int totalSessions;
  final int sessionsAttended;
  final double attendancePercentage;
  final List<StudentAttendanceSessionRecord> recentSessions;

  const StudentSubjectDetailResponse({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.teacherName,
    required this.totalSessions,
    required this.sessionsAttended,
    required this.attendancePercentage,
    required this.recentSessions,
  });

  int get sessionsAbsent =>
      (totalSessions - sessionsAttended).clamp(0, 0x7fffffff);

  factory StudentSubjectDetailResponse.fromJson(Map<String, dynamic> json) {
    final list = json['recent_sessions'] as List<dynamic>? ?? [];
    return StudentSubjectDetailResponse(
      courseId: json['course_id']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
      courseName: _sanitizeApiName(json['course_name']?.toString()) ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      sessionsAttended: (json['sessions_attended'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendance_percentage'] as num?)?.toDouble() ?? 0,
      recentSessions: list
          .map((e) => StudentAttendanceSessionRecord.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}
