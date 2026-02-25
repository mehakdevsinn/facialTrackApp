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
}
