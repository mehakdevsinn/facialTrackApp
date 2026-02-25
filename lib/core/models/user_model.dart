class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String accountStatus;
  final bool emailVerified;
  final bool faceVerified;
  final String? rollNumber;
  final String? department;
  final String? semester;
  final String? section;
  final String? phoneNumber;
  final String? designation;
  final String? qualification;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.accountStatus,
    required this.emailVerified,
    required this.faceVerified,
    this.rollNumber,
    this.department,
    this.semester,
    this.section,
    this.phoneNumber,
    this.designation,
    this.qualification,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      accountStatus: json['account_status'] ?? 'pending',
      emailVerified: json['email_verified'] ?? false,
      faceVerified: json['face_verified'] ?? false,
      rollNumber: json['roll_number'],
      department: json['department'],
      semester: json['semester'],
      section: json['section'],
      phoneNumber: json['phone_number'],
      designation: json['designation'],
      qualification: json['qualification'],
    );
  }

  bool get isApproved => accountStatus == 'approved';
  bool get isPending => accountStatus == 'pending';
  bool get isRejected => accountStatus == 'rejected';
  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isAdmin => role == 'admin';
}
