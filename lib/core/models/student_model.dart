class StudentModel {
  final String id;
  final String fullName;
  final String rollNo;
  final String email;
  final int semesterNumber;
  final String section;
  final String
      enrollmentDate; // "2024-09-01T00:00:00" – display date portion only
  final bool faceEnrolled;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.rollNo,
    required this.email,
    required this.semesterNumber,
    required this.section,
    required this.enrollmentDate,
    required this.faceEnrolled,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      rollNo: json['roll_no'] ?? '',
      email: json['email'] ?? '',
      semesterNumber: json['semester_number'] ?? 1,
      section: json['section'] ?? 'A',
      enrollmentDate: json['enrollment_date'] ?? '',
      faceEnrolled: json['face_enrolled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'roll_no': rollNo,
        'email': email,
        'semester_number': semesterNumber,
        'section': section,
        'enrollment_date': enrollmentDate,
        'face_enrolled': faceEnrolled,
      };

  StudentModel copyWith({
    String? fullName,
    String? rollNo,
    String? email,
    int? semesterNumber,
    String? section,
  }) {
    return StudentModel(
      id: id,
      fullName: fullName ?? this.fullName,
      rollNo: rollNo ?? this.rollNo,
      email: email ?? this.email,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      section: section ?? this.section,
      enrollmentDate: enrollmentDate,
      faceEnrolled: faceEnrolled,
    );
  }

  /// Returns the date portion only, e.g. "2024-09-01" from the ISO datetime.
  String get displayDate => enrollmentDate.length >= 10
      ? enrollmentDate.substring(0, 10)
      : enrollmentDate;

  /// Two-letter initials from the full name.
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
