class AssignmentTeacher {
  final String id;
  final String fullName;
  final String designation;

  const AssignmentTeacher({
    required this.id,
    required this.fullName,
    required this.designation,
  });

  factory AssignmentTeacher.fromJson(Map<String, dynamic> json) =>
      AssignmentTeacher(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        designation: json['designation'] as String,
      );

  /// Initials from full_name (up to 2 letters)
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class AssignmentCourse {
  final String id;
  final String code;
  final String name;
  final int creditHours;
  final String semesterId;

  const AssignmentCourse({
    required this.id,
    required this.code,
    required this.name,
    required this.creditHours,
    required this.semesterId,
  });

  factory AssignmentCourse.fromJson(Map<String, dynamic> json) =>
      AssignmentCourse(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        creditHours: json['credit_hours'] as int,
        semesterId: json['semester_id'] as String,
      );
}

class AssignmentModel {
  final String id;
  final String section;
  final AssignmentTeacher teacher;
  final AssignmentCourse course;

  const AssignmentModel({
    required this.id,
    required this.section,
    required this.teacher,
    required this.course,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      AssignmentModel(
        id: json['id'] as String,
        section: json['section'] as String,
        teacher:
            AssignmentTeacher.fromJson(json['teacher'] as Map<String, dynamic>),
        course:
            AssignmentCourse.fromJson(json['course'] as Map<String, dynamic>),
      );
}
