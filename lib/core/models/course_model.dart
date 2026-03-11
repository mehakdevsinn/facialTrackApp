/// Represents a single course/subject returned by API
class CourseModel {
  final String id;
  final String code;
  final String name;
  final String semesterId;
  final String? teacherId;
  final String description;
  final int creditHours;
  final bool attendanceRequired;
  final bool isActive;

  const CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.semesterId,
    this.teacherId,
    required this.description,
    required this.creditHours,
    required this.attendanceRequired,
    required this.isActive,
  });

  // ── JSON → Model ──────────────────────────────────────────────────────────
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      semesterId: json['semester_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString(),
      description: json['description']?.toString() ?? '',
      creditHours: (json['credit_hours'] as num?)?.toInt() ?? 3,
      attendanceRequired: json['attendance_required'] == true,
      isActive: json['is_active'] == true,
    );
  }

  // ── Model → JSON (for POST/PUT body) ──────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'semester_id': semesterId,
        'description': description,
        'credit_hours': creditHours,
        'attendance_required': attendanceRequired,
        'is_active': isActive,
      };

  @override
  String toString() => '$code: $name';
}
