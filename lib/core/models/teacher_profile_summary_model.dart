class TeacherAssignedSubject {
  final String courseName;
  final String courseCode;
  final String section;
  final String semesterId;
  final String semesterLabel;
  final String academicSession;

  const TeacherAssignedSubject({
    required this.courseName,
    required this.courseCode,
    required this.section,
    required this.semesterId,
    required this.semesterLabel,
    required this.academicSession,
  });

  factory TeacherAssignedSubject.fromJson(Map<String, dynamic> json) {
    return TeacherAssignedSubject(
      courseName: json['course_name']?.toString() ??
          json['name']?.toString() ??
          'Unknown Subject',
      courseCode: json['course_code']?.toString() ??
          json['code']?.toString() ??
          'N/A',
      section: json['section']?.toString() ?? '—',
      semesterId: json['semester_id']?.toString() ??
          json['semester']?.toString() ??
          '—',
      semesterLabel: json['semester_label']?.toString() ??
          json['semester_id']?.toString() ??
          json['semester']?.toString() ??
          '—',
      academicSession: json['academic_session']?.toString() ?? '—',
    );
  }
}

class TeacherProfileSummaryModel {
  final int subjectsAssignedCount;
  final int totalClassesHandled;
  final int activeSessionsCount;
  final List<TeacherAssignedSubject> subjectsAssigned;

  const TeacherProfileSummaryModel({
    required this.subjectsAssignedCount,
    required this.totalClassesHandled,
    required this.activeSessionsCount,
    required this.subjectsAssigned,
  });

  factory TeacherProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    final subjectsRaw = (json['subjects_assigned'] as List?) ?? const [];
    final parsedSubjects = subjectsRaw
        .map((e) => TeacherAssignedSubject.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();

    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return TeacherProfileSummaryModel(
      subjectsAssignedCount: parseInt(
          json['subjects_assigned_count'], parsedSubjects.length),
      totalClassesHandled: parseInt(json['total_classes_handled'], 0),
      activeSessionsCount: parseInt(json['active_sessions_count'], 0),
      subjectsAssigned: parsedSubjects,
    );
  }
}
