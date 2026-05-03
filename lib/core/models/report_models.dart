class CourseReportStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final int sessionsAttended;
  final int totalSessions;
  final double attendancePercentage;
  final int lateCount;
  /// Excused leave session count (Policy B — excluded from % denominator).
  final int sessionsOnLeave;
  /// Unexcused missed sessions only (from API `sessions_missed` when sent).
  final int sessionsMissedUnexcused;
  /// Present when API includes per-student verification (e.g. dominant method).
  final String? verificationMethod;

  const CourseReportStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.sessionsAttended,
    required this.totalSessions,
    required this.attendancePercentage,
    required this.lateCount,
    this.sessionsOnLeave = 0,
    required this.sessionsMissedUnexcused,
    this.verificationMethod,
  });

  /// Alias for PDFs / legacy call sites: unexcused absences only.
  int get sessionsMissed => sessionsMissedUnexcused;

  factory CourseReportStudent.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final totalSessions = parseInt(json['total_sessions']);
    final sessionsAttended = parseInt(json['sessions_attended']);
    final sessionsOnLeave = parseInt(json['sessions_on_leave']);
    final missedFromApi = json['sessions_missed'];
    final sessionsMissedUnexcused = missedFromApi != null
        ? parseInt(missedFromApi)
        : (totalSessions - sessionsAttended - sessionsOnLeave).clamp(0, 1 << 30);

    return CourseReportStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Unknown',
      rollNumber: json['roll_number']?.toString() ?? '—',
      sessionsAttended: sessionsAttended,
      totalSessions: totalSessions,
      attendancePercentage: parseDouble(json['attendance_percentage']),
      lateCount: parseInt(json['late_count']),
      sessionsOnLeave: sessionsOnLeave,
      sessionsMissedUnexcused: sessionsMissedUnexcused,
      verificationMethod: json['verification_method']?.toString() ??
          json['dominant_verification_method']?.toString(),
    );
  }
}

class CourseDateRangeModel {
  final String? start;
  final String? end;

  const CourseDateRangeModel({this.start, this.end});

  factory CourseDateRangeModel.fromJson(Map<String, dynamic> json) {
    return CourseDateRangeModel(
      start: json['start']?.toString(),
      end: json['end']?.toString(),
    );
  }
}

class CourseReportResponse {
  final String courseId;
  final String courseName;
  final int totalSessions;
  final double courseAveragePercentage;
  final CourseDateRangeModel? dateRange;
  final List<CourseReportStudent> students;

  const CourseReportResponse({
    required this.courseId,
    required this.courseName,
    required this.totalSessions,
    required this.courseAveragePercentage,
    required this.students,
    this.dateRange,
  });

  factory CourseReportResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final studentsRaw = (json['students'] as List?) ?? const [];
    return CourseReportResponse(
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? 'Course',
      totalSessions: parseInt(json['total_sessions']),
      courseAveragePercentage: parseDouble(json['course_average_percentage']),
      dateRange: json['date_range'] is Map<String, dynamic>
          ? CourseDateRangeModel.fromJson(
              json['date_range'] as Map<String, dynamic>)
          : null,
      students: studentsRaw
          .map((e) => CourseReportStudent.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class MonthlySessionSummary {
  final String sessionId;
  final String sessionDate;
  final int presentCount;
  final int absentCount;
  final int onLeaveCount;
  final int totalEnrolled;

  const MonthlySessionSummary({
    required this.sessionId,
    required this.sessionDate,
    required this.presentCount,
    required this.absentCount,
    this.onLeaveCount = 0,
    required this.totalEnrolled,
  });

  factory MonthlySessionSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return MonthlySessionSummary(
      sessionId: json['session_id']?.toString() ?? '',
      sessionDate: json['session_date']?.toString() ?? '',
      presentCount: parseInt(json['present_count']),
      absentCount: parseInt(json['absent_count']),
      onLeaveCount: parseInt(json['on_leave_count']),
      totalEnrolled: parseInt(json['total_enrolled']),
    );
  }
}

class MonthlyReportResponse {
  final String courseId;
  final String courseName;
  final int year;
  final int month;
  final int totalSessions;
  final double overallAttendancePercentage;
  final int totalPresentAcrossSessions;
  final int totalAbsentAcrossSessions;
  final List<CourseReportStudent> students;
  final List<MonthlySessionSummary> sessions;

  const MonthlyReportResponse({
    required this.courseId,
    required this.courseName,
    required this.year,
    required this.month,
    required this.totalSessions,
    required this.overallAttendancePercentage,
    required this.totalPresentAcrossSessions,
    required this.totalAbsentAcrossSessions,
    required this.students,
    required this.sessions,
  });

  factory MonthlyReportResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final studentsRaw = (json['students'] as List?) ?? const [];
    final sessionsRaw = (json['sessions'] as List?) ?? const [];
    return MonthlyReportResponse(
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? 'Course',
      year: parseInt(json['year']),
      month: parseInt(json['month']),
      totalSessions: parseInt(json['total_sessions']),
      overallAttendancePercentage:
          parseDouble(json['overall_attendance_percentage']),
      totalPresentAcrossSessions: parseInt(json['total_present_across_sessions']),
      totalAbsentAcrossSessions: parseInt(json['total_absent_across_sessions']),
      students: studentsRaw
          .map((e) => CourseReportStudent.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      sessions: sessionsRaw
          .map((e) => MonthlySessionSummary.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class DailyReportStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final bool isPresent;
  final bool isOnLeave;
  final String? leaveReason;
  final String? markedAt;
  final String? verificationMethod;

  const DailyReportStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.isPresent,
    this.isOnLeave = false,
    this.leaveReason,
    this.markedAt,
    this.verificationMethod,
  });

  factory DailyReportStudent.fromJson(Map<String, dynamic> json) {
    return DailyReportStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Unknown',
      rollNumber: json['roll_number']?.toString() ?? '—',
      isPresent: json['is_present'] == true,
      isOnLeave: json['is_on_leave'] == true || json['on_leave'] == true,
      leaveReason: json['leave_reason']?.toString(),
      markedAt: json['marked_at']?.toString(),
      verificationMethod: json['verification_method']?.toString(),
    );
  }
}

class DailyReportResponse {
  final String courseId;
  final String courseName;
  final String reportDate;
  final int totalEnrolled;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;
  final List<DailyReportStudent> students;

  const DailyReportResponse({
    required this.courseId,
    required this.courseName,
    required this.reportDate,
    required this.totalEnrolled,
    required this.presentCount,
    required this.absentCount,
    required this.attendancePercentage,
    required this.students,
  });

  factory DailyReportResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final studentsRaw = (json['students'] as List?) ?? const [];
    return DailyReportResponse(
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? 'Course',
      reportDate: json['report_date']?.toString() ?? '',
      totalEnrolled: parseInt(json['total_enrolled']),
      presentCount: parseInt(json['present_count']),
      absentCount: parseInt(json['absent_count']),
      attendancePercentage: parseDouble(json['attendance_percentage']),
      students: studentsRaw
          .map((e) =>
              DailyReportStudent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class LowAttendanceStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String courseName;
  final double attendancePercentage;
  final int sessionsAttended;
  final int totalSessions;
  final int sessionsMissed;
  final int sessionsOnLeave;

  const LowAttendanceStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.courseName,
    required this.attendancePercentage,
    required this.sessionsAttended,
    required this.totalSessions,
    required this.sessionsMissed,
    this.sessionsOnLeave = 0,
  });

  factory LowAttendanceStudent.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return LowAttendanceStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Unknown',
      rollNumber: json['roll_number']?.toString() ?? '—',
      courseName: json['course_name']?.toString() ?? 'Course',
      attendancePercentage: parseDouble(json['attendance_percentage']),
      sessionsAttended: parseInt(json['sessions_attended']),
      totalSessions: parseInt(json['total_sessions']),
      sessionsMissed: parseInt(json['sessions_missed']),
      sessionsOnLeave: parseInt(json['sessions_on_leave']),
    );
  }
}
