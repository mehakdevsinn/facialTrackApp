/// Represents a student returned by
/// GET /teachers/{teacher_id}/courses/{course_id}/students
class RosterStudentModel {
  final String id;
  final String fullName;
  final String? rollNumber;
  final String? email;
  final int? semester;

  const RosterStudentModel({
    required this.id,
    required this.fullName,
    this.rollNumber,
    this.email,
    this.semester,
  });

  factory RosterStudentModel.fromJson(Map<String, dynamic> json) {
    return RosterStudentModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString(),
      email: json['email']?.toString(),
      semester: (json['semester_number'] as num?)?.toInt(),
    );
  }

  /// Two-letter initials for avatar display (e.g. "AK").
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  @override
  String toString() => fullName;
}
