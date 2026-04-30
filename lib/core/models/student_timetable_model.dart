/// Student timetable (`GET /api/v1/students/schedule/`) — same shape as admin timetable.
class TimetablePeriod {
  final String id;
  final bool isBreak;
  final String label;
  final String startTime;
  final String endTime;

  const TimetablePeriod({
    required this.id,
    required this.isBreak,
    required this.label,
    required this.startTime,
    required this.endTime,
  });

  factory TimetablePeriod.fromJson(Map<String, dynamic> json) {
    return TimetablePeriod(
      id: json['id']?.toString() ?? '',
      isBreak: json['is_break'] == true,
      label: json['label']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class TimetableEntry {
  final String day;
  final String periodId;
  final String? assignmentId;
  final String? courseCode;
  final String? courseTitle;
  final String? teacherName;
  final String? section;

  const TimetableEntry({
    required this.day,
    required this.periodId,
    this.assignmentId,
    this.courseCode,
    this.courseTitle,
    this.teacherName,
    this.section,
  });

  bool get isUnassigned =>
      assignmentId == null ||
      assignmentId!.trim().isEmpty ||
      assignmentId == 'null';

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      day: json['day']?.toString() ?? '',
      periodId: json['period_id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString(),
      courseCode: json['course_code']?.toString(),
      courseTitle: json['course_title']?.toString(),
      teacherName: json['teacher_name']?.toString(),
      section: json['section']?.toString(),
    );
  }
}

class StudentTimetableResponse {
  final String id;
  final String semesterId;
  final int semesterNumber;
  final String academicSession;
  final String section;
  final List<TimetablePeriod> periods;
  final List<TimetableEntry> entries;

  const StudentTimetableResponse({
    required this.id,
    required this.semesterId,
    required this.semesterNumber,
    required this.academicSession,
    required this.section,
    required this.periods,
    required this.entries,
  });

  factory StudentTimetableResponse.fromJson(Map<String, dynamic> json) {
    final periodList = json['periods'] as List<dynamic>? ?? [];
    final entryList = json['entries'] as List<dynamic>? ?? [];
    return StudentTimetableResponse(
      id: json['id']?.toString() ?? '',
      semesterId: json['semester_id']?.toString() ?? '',
      semesterNumber: (json['semester_number'] as num?)?.toInt() ?? 0,
      academicSession: json['academic_session']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      periods: periodList
          .map((e) => TimetablePeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
      entries: entryList
          .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
