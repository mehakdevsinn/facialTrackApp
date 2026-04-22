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

  // ── Admin — Assignments ───────────────────────────────────────────────────
  /// GET → all assignments  |  POST → create a new assignment
  static const String adminAssignments = '$_admin/assignments';

  /// PUT → update assignment  |  DELETE → remove assignment (keep here for clarity)

  /// GET → assignments filtered by semester + section (for schedule dropdowns)
  static String adminAssignmentsFiltered({String? semesterId, String? section}) {
    final params = <String, String>{};
    if (semesterId != null) params['semester_id'] = semesterId;
    if (section != null) params['section'] = section;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return query.isEmpty ? adminAssignments : '$adminAssignments?$query';
  }


  // ── Admin — Schedule ──────────────────────────────────────────────────────
  /// GET → list all timetables  |  POST → create a new timetable
  static const String adminSchedule = '$_admin/schedule/';

  /// GET → single timetable  |  DELETE → remove it
  static String adminTimetable(String id) => '$_admin/schedule/$id';

  /// PATCH → replace period list for a timetable
  static String adminTimetablePeriods(String id) =>
      '$_admin/schedule/$id/periods';

  /// PUT → assign/update a slot  |  DELETE → clear a slot
  static String adminTimetableEntries(String id) =>
      '$_admin/schedule/$id/entries';

  /// PUT → update assignment  |  DELETE → remove assignment
  static String adminAssignment(String assignmentId) =>
      '$_admin/assignments/$assignmentId';

  // ── Admin — Student Approval ─────────────────────────────────────────────
  /// GET → list all pending students
  static const String adminStudentsPending = '$_admin/students/pending';

  /// POST → approve a specific student
  static String adminStudentApprove(String studentId) =>
      '$_admin/students/$studentId/approve';

  /// POST → reject a specific student
  static String adminStudentReject(String studentId) =>
      '$_admin/students/$studentId/reject';

  // ── Admin — Student Management ────────────────────────────────────────────
  /// GET → list all enrolled students (also used for dashboard count)
  static const String adminAllStudents = '$_admin/students/';

  /// GET → single student  |  PUT → update  |  DELETE → remove
  static String adminStudent(String studentId) => '$_admin/students/$studentId';

  /// POST → promote a list of students to the next semester
  static const String adminStudentsBulkPromote =
      '$_admin/students/bulk-promote';

  /// POST → permanently delete a list of students
  static const String adminStudentsBulkDelete = '$_admin/students/bulk-delete';

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

  // ── Student — Enrollment Window ──────────────────────────────────────────
  /// GET → returns enrollment_open flag + deadline + student_enrolled status
  static const String enrollmentWindow =
      '$_face/students/face/enrollment-window';

  // ── Admin — Enrollment Deadline Settings ─────────────────────────────────
  static const String _adminSettings = '$_admin/settings';

  /// GET  → fetch current deadline  |  PUT → set / update deadline
  static const String enrollmentDeadline =
      '$_adminSettings/enrollment-deadline';

  /// GET → fetch attendance threshold  |  PUT → set/update threshold
  static const String attendanceCriteria =
      '$_adminSettings/attendance-criteria';

  // ── Teacher — Session Flow ────────────────────────────────────────────────
  static const String _teacher = '$baseUrl/api/v1/teachers';

  /// GET → active courses for this teacher (with nested semester object).
  static String teacherCourses(String teacherId) =>
      '$_teacher/$teacherId/courses';

  /// GET → approved students whose semester matches the course's semester ordinal.
  static String teacherCourseStudents(String teacherId, String courseId) =>
      '$_teacher/$teacherId/courses/$courseId/students';

  /// POST → create a new session  |  GET → all sessions (optional ?active_only=true)
  static const String teacherSessions = '$_teacher/sessions';

  /// GET → sessions for this teacher that are currently inside [start_time, end_time].
  static const String teacherActiveSessions = '$_teacher/sessions/active';

  /// GET → all attendance records for a session
  /// POST → mark a student present manually
  static String teacherSessionAttendance(String sessionId) =>
      '$_teacher/sessions/$sessionId/attendance';

  /// DELETE → remove a student's attendance row (mark absent after the fact).
  static String teacherSessionAttendanceStudent(
          String sessionId, String studentId) =>
      '$_teacher/sessions/$sessionId/attendance/$studentId';

  /// POST → stop/finalise a session → 200 + SessionResponse (is_active = false).
  static String teacherSessionStop(String sessionId) =>
      '$_teacher/sessions/$sessionId/stop';

  /// GET → teacher's timetable slots.
  /// Pass [semesterId]+[section] together, or [timetableId] alone.
  /// Optional [forDate] ("YYYY-MM-DD") filters by calendar weekday.
  static String teacherSchedule(String teacherId) =>
      '$_teacher/$teacherId/schedule';

  /// GET → all assigned schedule slots for teacher.
  static String teacherScheduleAll(String teacherId) =>
      '$_teacher/$teacherId/schedule/all';

  /// GET → profile summary stats + assigned subjects list.
  static String teacherProfileSummary(String teacherId) =>
      '$_teacher/$teacherId/profile-summary';
}
