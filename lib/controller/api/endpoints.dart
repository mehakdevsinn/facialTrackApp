// All API endpoint URLs are defined here as constants.
// Import this file wherever a URL is needed — never hardcode URLs in other files.

class Endpoints {
  Endpoints._(); // prevent instantiation

  // ── Base ─────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://facialtrackapp.site';
  static const String _auth = '$baseUrl/api/v1/auth';
  static const String _admin = '$baseUrl/api/v1/admin';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String register = '$_auth/register';
  static const String login = '$_auth/login';
  static const String verifyOtp = '$_auth/verify-otp';
  static const String resendOtp = '$_auth/resend-otp';
  static const String forgotPassword = '$_auth/forgot-password';
  static const String verifyResetOtp = '$_auth/verify-reset-otp';
  static const String resendResetOtp = '$_auth/resend-reset-otp';
  static const String resetPassword = '$_auth/reset-password';
  static const String changePassword = '$_auth/change-password';

  // ── Admin — Teachers ─────────────────────────────────────────────────────
  static const String adminTeachers = '$_admin/teachers/';

  /// Returns the URL for updating or deleting a specific teacher.
  /// Usage: `Endpoints.adminTeacher('some-uuid')`
  static String adminTeacher(String teacherId) => '$_admin/teachers/$teacherId';

  // ── Admin — Semesters ────────────────────────────────────────────────────
  /// GET → list all semesters  |  POST → create a new semester
  static const String adminSemesters = '$_admin/semesters';

  /// PUT → update a specific semester by id
  static String adminSemester(String semesterId) =>
      '$_admin/semesters/$semesterId';

  // ── Admin — Courses ──────────────────────────────────────────────────────
  static const String adminCourses = '$_admin/courses';

  /// GET → list courses for a specific semester
  static String adminCoursesBySemester(String semesterId) =>
      '$_admin/courses/by-semester/$semesterId';

  /// PUT → update a specific course by id
  static String adminCourse(String courseId) => '$_admin/courses/$courseId';

  // ── Admin — Student Approval ─────────────────────────────────────────────
  /// GET → list all pending students
  static const String adminStudentsPending = '$_admin/students/pending';

  /// POST → approve a specific student
  static String adminStudentApprove(String studentId) =>
      '$_admin/students/$studentId/approve';

  /// POST → reject a specific student
  static String adminStudentReject(String studentId) =>
      '$_admin/students/$studentId/reject';

  // ── Student — Face Enrollment ─────────────────────────────────────────────
  static const String _face = '$baseUrl/api/v1';

  /// GET → fetch capture sequence + config (call once on screen open)
  static const String enrollmentConfig = '$_face/enrollment-config';

  /// POST → send a camera frame for real-time analysis (multipart/form-data)
  static const String analyzeFrame = '$_face/analyze-frame';

  /// POST → upload a captured face image (multipart/form-data, angle as form field)
  static const String faceUpload = '$_face/students/face/upload';

  /// GET → check if the student already has face images uploaded
  static const String faceStatus = '$_face/students/face/status';
}
