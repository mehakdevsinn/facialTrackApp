import 'package:facialtrackapp/core/models/semester_model.dart';

/// Represents a course returned by GET /teachers/{teacher_id}/courses.
/// Unlike the admin CourseModel, this includes the nested [semester] object.
class TeacherCourseModel {
  final String id;
  final String code;
  final String name;
  final String semesterId;
  final String? teacherId;
  final String? description;
  final int creditHours;
  final bool attendanceRequired;
  final bool isActive;

  /// Always populated on the teacher courses endpoint.
  final SemesterModel? semester;

  const TeacherCourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.semesterId,
    this.teacherId,
    this.description,
    required this.creditHours,
    required this.attendanceRequired,
    required this.isActive,
    this.semester,
  });

  factory TeacherCourseModel.fromJson(Map<String, dynamic> json) {
    return TeacherCourseModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      semesterId: json['semester_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString(),
      description: json['description']?.toString(),
      creditHours: (json['credit_hours'] as num?)?.toInt() ?? 3,
      attendanceRequired: json['attendance_required'] == true,
      isActive: json['is_active'] == true,
      semester: json['semester'] != null
          ? SemesterModel.fromJson(json['semester'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Human-readable display label for the subject dropdown.
  String get displayName => '$code — $name';

  @override
  String toString() => displayName;
}
