/// Represents a student awaiting admin approval.
/// Maps to the GET /api/v1/admin/students/pending response object.
class PendingStudentModel {
  final String id;
  final String fullName;
  final String email;
  final String rollNumber;
  final String department;
  final String semester;
  final String section;
  final String createdAt; // ISO-8601

  const PendingStudentModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.section,
    required this.createdAt,
  });

  factory PendingStudentModel.fromJson(Map<String, dynamic> json) {
    return PendingStudentModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rollNumber: json['roll_number'] as String? ?? '',
      department: json['department'] as String? ?? '',
      semester: json['semester'] as String? ?? '',
      section: json['section'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// Friendly registration date, e.g. "06 Mar 2026"
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day.toString().padLeft(2, '0')} '
          '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  /// Initials for avatar (up to 2 letters)
  String get initials {
    final parts = fullName.trim().split(' ');
    return parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }
}
