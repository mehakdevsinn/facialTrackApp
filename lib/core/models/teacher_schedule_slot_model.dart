/// Represents one slot returned by
/// GET /teachers/{teacher_id}/schedule
class TeacherScheduleSlotModel {
  final String timetableId;
  final String semesterId;
  final String section;
  final String academicSession;

  /// Weekday abbreviation e.g. "Mon", "Tue", "Wed", "Thu", "Fri"
  final String day;

  final String periodId;

  /// Human-readable label e.g. "Period 1"
  final String periodLabel;

  /// "HH:MM" 24-hour string from backend
  final String startTime;

  /// "HH:MM" 24-hour string from backend
  final String endTime;

  final String assignmentId;
  final String courseId;
  final String courseCode;
  final String courseName;

  const TeacherScheduleSlotModel({
    required this.timetableId,
    required this.semesterId,
    required this.section,
    required this.academicSession,
    required this.day,
    required this.periodId,
    required this.periodLabel,
    required this.startTime,
    required this.endTime,
    required this.assignmentId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });

  factory TeacherScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleSlotModel(
      timetableId: json['timetable_id']?.toString() ?? '',
      semesterId: json['semester_id']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      academicSession: json['academic_session']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      periodId: json['period_id']?.toString() ?? '',
      periodLabel: json['period_label']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// e.g. "09:00 – 10:00"
  String get displayTime => '$startTime – $endTime';

  /// Combines [forDate] calendar date with this slot's [startTime] "HH:MM"
  /// into a UTC ISO 8601 string for POST /teachers/sessions.
  String startIso(DateTime forDate) => _combine(forDate, startTime);

  /// Combines [forDate] calendar date with this slot's [endTime] "HH:MM"
  /// into a UTC ISO 8601 string for POST /teachers/sessions.
  String endIso(DateTime forDate) => _combine(forDate, endTime);

  static String _combine(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final local = DateTime(date.year, date.month, date.day, h, m);
    return local.toUtc().toIso8601String();
  }

  @override
  String toString() => '$courseCode — $periodLabel ($displayTime)';
}
