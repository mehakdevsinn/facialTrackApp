import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:facialtrackapp/controller/api/endpoints.dart';
import 'package:facialtrackapp/core/models/assignment_model.dart';
import 'package:facialtrackapp/core/models/course_model.dart';
import 'package:facialtrackapp/core/models/enrollment_config_model.dart';
import 'package:facialtrackapp/core/models/enrollment_window_model.dart';
import 'package:facialtrackapp/core/models/face_status_model.dart';
import 'package:facialtrackapp/core/models/frame_analysis_result.dart';
import 'package:facialtrackapp/core/models/pending_student_model.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/student_model.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:facialtrackapp/core/models/roster_student_model.dart';
import 'package:facialtrackapp/core/models/attendance_record_model.dart';
import 'package:facialtrackapp/core/models/teacher_schedule_slot_model.dart';
import 'package:facialtrackapp/core/models/teacher_profile_summary_model.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/models/student_settings_model.dart';
import 'package:facialtrackapp/core/models/student_timetable_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// ─── Custom Exception ─────────────────────────────────────────────────────────
// Named AuthException so every existing `on AuthException catch` block works.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

// ── Account-state exceptions (thrown from login()) ───────────────────────────

/// Thrown when the backend returns 403 with "pending" in the detail message.
class AccountPendingException implements Exception {
  final String message;
  const AccountPendingException([this.message = 'Account pending approval.']);
  @override
  String toString() => message;
}

/// Thrown when the backend returns 403 with "rejected" in the detail message.
class AccountRejectedException implements Exception {
  final String message;
  const AccountRejectedException([this.message = 'Account rejected.']);
  @override
  String toString() => message;
}

// ─── API Manager ──────────────────────────────────────────────────────────────
class ApiManager {
  ApiManager._();
  static final ApiManager instance = ApiManager._();

  // ── Shared headers ────────────────────────────────────────────────────────
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      ..._jsonHeaders,
      'Authorization': 'Bearer $token',
    };
  }

  // ── Error handler ─────────────────────────────────────────────────────────
  AuthException _handleError(dynamic error, {http.Response? response}) {
    if (kDebugMode) {
      debugPrint('== API ERROR ==');
      debugPrint(error.toString());
      if (response != null) debugPrint('Response body: ${response.body}');
    }

    if (error is SocketException) {
      return AuthException('Cannot connect to server. Check your internet.');
    }
    if (error is TimeoutException) {
      return AuthException(
        'The server is taking too long to respond. '
        'Your request may still be processing — please wait a moment before trying again.',
      );
    }
    if (response != null) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = body['detail'];
        if (detail != null) return AuthException(detail.toString());
      } catch (_) {}
      return AuthException('Server error (${response.statusCode}).');
    }
    return AuthException('An unexpected error occurred: ${error.toString()}');
  }

  /// Throws [AuthException] if status code >= 400.
  /// For login-specific 403 responses, throws [AccountPendingException] or
  /// [AccountRejectedException] instead so the UI can route accordingly.
  void _assertSuccess(http.Response response) {
    if (response.statusCode >= 400) {
      throw _handleError('HTTP ${response.statusCode}', response: response);
    }
  }

  // ─── 1. REGISTER ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? rollNumber,
    String? department,
    String? semester,
    String? section,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      };
      if (role == 'student') {
        body['roll_number'] = rollNumber;
        body['department'] = department;
        body['semester'] = semester;
        if (section != null && section.isNotEmpty) body['section'] = section;
      }

      final response = await http
          .post(Uri.parse(Endpoints.register),
              headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 2. VERIFY OTP ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.verifyOtp),
              headers: _jsonHeaders,
              body: jsonEncode({'email': email, 'otp_code': otpCode}))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['access_token'] != null) {
        await StorageService.saveToken(data['access_token']);
      }
      if (data['user'] != null) {
        final user = UserModel.fromJson(data['user']);
        await StorageService.saveUserInfo(
          email: user.email,
          userId: user.id,
          role: user.role,
          fullName: user.fullName,
        );
      }
      return data;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 3. RESEND OTP (Registration flow) ──────────────────────────────────
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.resendOtp),
              headers: _jsonHeaders, body: jsonEncode({'email': email}))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 4. RESEND RESET OTP ─────────────────────────────────────────────────
  Future<void> resendResetOtp({required String email}) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.resendResetOtp),
              headers: _jsonHeaders, body: jsonEncode({'email': email}))
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 5. FORGOT PASSWORD ───────────────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.forgotPassword),
              headers: _jsonHeaders, body: jsonEncode({'email': email}))
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 6. VERIFY RESET OTP ──────────────────────────────────────────────────
  Future<void> verifyResetOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.verifyResetOtp),
              headers: _jsonHeaders,
              body: jsonEncode({'email': email, 'otp_code': otpCode}))
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 7. RESET PASSWORD ────────────────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.resetPassword),
              headers: _jsonHeaders,
              body: jsonEncode({
                'email': email,
                'otp_code': otpCode,
                'new_password': newPassword,
              }))
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 8. LOGIN ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.login),
              headers: _jsonHeaders,
              body: jsonEncode({'email': email, 'password': password}))
          .timeout(const Duration(seconds: 30));

      // Detect account-state 403s BEFORE the generic _assertSuccess
      if (response.statusCode == 403) {
        String detail = '';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          detail = (body['detail'] ?? '').toString().toLowerCase();
        } catch (_) {}
        if (detail.contains('pending')) throw const AccountPendingException();
        if (detail.contains('rejected')) throw const AccountRejectedException();
      }

      _assertSuccess(response);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['access_token'] != null) {
        await StorageService.saveToken(data['access_token']);
      }
      if (data['user'] != null) {
        final user = UserModel.fromJson(data['user']);
        await StorageService.saveUserInfo(
          email: user.email,
          userId: user.id,
          role: user.role,
          fullName: user.fullName,
        );
      }
      return data;
    } on AccountPendingException {
      rethrow;
    } on AccountRejectedException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 9. GET CURRENT USER (Me) ────────────────────────────────────────────
  Future<UserModel> getMe() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Endpoints.baseUrl}/api/v1/auth/me'),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 10. LOGOUT ───────────────────────────────────────────────────────────
  Future<void> logout() async => StorageService.clearAll();

  // ─── 11. CHANGE PASSWORD ──────────────────────────────────────────────────
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(Endpoints.changePassword),
              headers: await _authHeaders(),
              body: jsonEncode({
                'old_password': oldPassword,
                'new_password': newPassword,
              }))
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 12. LIST ALL TEACHERS (Admin) ───────────────────────────────────────
  Future<List<UserModel>> getAllTeachers() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminTeachers),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 13. CREATE TEACHER (Admin) ──────────────────────────────────────────
  Future<UserModel> createTeacher({
    required String email,
    required String fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    try {
      final Map<String, dynamic> body = {'email': email, 'full_name': fullName};
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }
      if (designation != null && designation.isNotEmpty) {
        body['designation'] = designation;
      }
      if (qualification != null && qualification.isNotEmpty) {
        body['qualification'] = qualification;
      }

      final response = await http
          .post(Uri.parse(Endpoints.adminTeachers),
              headers: await _authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 14. UPDATE TEACHER (Admin) ──────────────────────────────────────────
  Future<UserModel> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (fullName != null && fullName.isNotEmpty) body['full_name'] = fullName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (designation != null) body['designation'] = designation;
      if (qualification != null) body['qualification'] = qualification;

      final response = await http
          .put(Uri.parse(Endpoints.adminTeacher(teacherId)),
              headers: await _authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DELETE TEACHER (Admin) ──────────────────────────────────────────────
  Future<void> deleteTeacher(String teacherId) async {
    try {
      final response = await http
          .delete(Uri.parse(Endpoints.adminTeacher(teacherId)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 204) {
        _assertSuccess(response);
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 15. LIST ALL SEMESTERS (Admin) ──────────────────────────────────────
  Future<List<SemesterModel>> getSemesters() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.adminSemesters),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Public/unauth semester listing used by student signup dropdown.
  Future<List<SemesterModel>> getSemestersForSignup() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.adminSemesters),
            headers: _jsonHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 16. CREATE SEMESTER (Admin) ─────────────────────────────────────────
  Future<SemesterModel> createSemester({
    required int semesterNumber,
    required String academicSession,
    required String termType,
    required String operationalStatus,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final body = {
        'semester_number': semesterNumber,
        'academic_session': academicSession,
        'term_type': termType,
        'operational_status': operationalStatus,
        'start_date': startDate,
        'end_date': endDate,
      };

      final response = await http
          .post(
            Uri.parse(Endpoints.adminSemesters),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return SemesterModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 17. UPDATE SEMESTER (Admin) ─────────────────────────────────────────
  Future<SemesterModel> updateSemester({
    required String semesterId,
    int? semesterNumber,
    String? academicSession,
    String? termType,
    String? operationalStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (semesterNumber != null) body['semester_number'] = semesterNumber;
      if (academicSession != null) body['academic_session'] = academicSession;
      if (termType != null) body['term_type'] = termType;
      if (operationalStatus != null) {
        body['operational_status'] = operationalStatus;
      }
      if (startDate != null) body['start_date'] = startDate;
      if (endDate != null) body['end_date'] = endDate;

      final response = await http
          .put(
            Uri.parse(Endpoints.adminSemester(semesterId)),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return SemesterModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 18. LIST PENDING STUDENTS (Admin) ──────────────────────────────────
  Future<List<PendingStudentModel>> getPendingStudents() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.adminStudentsPending),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => PendingStudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 19. APPROVE STUDENT (Admin) ──────────────────────────────────────
  Future<void> approveStudent(String studentId, {String? notes}) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.adminStudentApprove(studentId)),
            headers: await _authHeaders(),
            body: jsonEncode({'notes': notes ?? ''}),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 20. REJECT STUDENT (Admin) ───────────────────────────────────────
  Future<void> rejectStudent(String studentId, {String? notes}) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.adminStudentReject(studentId)),
            headers: await _authHeaders(),
            body: jsonEncode({'notes': notes ?? ''}),
          )
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // Face Enrollment
  // ────────────────────────────────────────────────────────────────────

  /// GET /enrollment-config
  /// Call once when the screen opens to get the capture sequence + fps.
  Future<EnrollmentConfig> getEnrollmentConfig() async {
    final headers = await _authHeaders();
    try {
      final response = await http
          .get(Uri.parse(Endpoints.enrollmentConfig), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw AuthException('Failed to load enrollment config.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return EnrollmentConfig.fromJson(body);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /analyze-frame
  /// Sends a JPEG frame to the backend and returns real-time guidance.
  /// [angle] must be one of: center, left, right.
  Future<FrameAnalysisResult> analyzeFrame(
      Uint8List jpegBytes, String angle) async {
    final token = await StorageService.getToken();
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(Endpoints.analyzeFrame))
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['angle'] = angle
            ..files.add(http.MultipartFile.fromBytes(
              'image',
              jpegBytes,
              filename: 'frame.jpg',
              contentType: MediaType('image', 'jpeg'),
            ));

      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401) {
        throw AuthException('Session expired. Please log in again.');
      }
      if (response.statusCode == 500) {
        // Guide says: skip 500 silently, return not-ready
        return FrameAnalysisResult.notReady;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return FrameAnalysisResult.fromJson(body);
    } on AuthException {
      rethrow;
    } catch (e) {
      // Network/timeout — treat as not-ready (Rule 3)
      return FrameAnalysisResult.notReady;
    }
  }

  /// POST /students/face/upload
  /// Uploads one captured face image. Call sequentially for each angle.
  /// [angle] is sent as a multipart form field (NOT a query param — per guide).
  Future<bool> uploadFaceImage(Uint8List jpegBytes, String angle) async {
    final token = await StorageService.getToken();
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(Endpoints.faceUpload))
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['angle'] = angle
            ..files.add(http.MultipartFile.fromBytes(
              'file',
              jpegBytes,
              filename: '$angle.jpg',
              contentType: MediaType('image', 'jpeg'),
            ));

      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401) {
        throw AuthException('Session expired. Please log in again.');
      }
      if (response.statusCode != 200) {
        throw AuthException(
            'Upload failed for $angle angle. Please try re-enrolling.');
      }
      return true;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /students/face/status
  /// Returns whether the student has uploaded face images and how many.
  Future<FaceStatusModel> getFaceStatus() async {
    final headers = await _authHeaders();
    try {
      final response = await http
          .get(Uri.parse(Endpoints.faceStatus), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw AuthException('Failed to fetch face status.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return FaceStatusModel.fromJson(body);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ADMIN — COURSES ──────────────────────────────────────────────────────

  /// GET /admin/courses/by-semester/{semesterId}
  Future<List<CourseModel>> getCoursesBySemester(String semesterId) async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminCoursesBySemester(semesterId)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /admin/courses
  Future<CourseModel> createCourse({
    required String code,
    required String name,
    required String semesterId,
    String description = '',
    int creditHours = 3,
    bool attendanceRequired = true,
  }) async {
    try {
      final body = {
        'code': code,
        'name': name,
        'semester_id': semesterId,
        'description': description,
        'credit_hours': creditHours,
        'attendance_required': attendanceRequired,
      };

      final response = await http
          .post(Uri.parse(Endpoints.adminCourses),
              headers: await _authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return CourseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /admin/courses/{id}
  Future<CourseModel> updateCourse({
    required String courseId,
    String? code,
    String? name,
    String? description,
    int? creditHours,
    bool? attendanceRequired,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (code != null) body['code'] = code;
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (creditHours != null) body['credit_hours'] = creditHours;
      if (attendanceRequired != null) {
        body['attendance_required'] = attendanceRequired;
      }
      if (isActive != null) body['is_active'] = isActive;

      final response = await http
          .put(Uri.parse(Endpoints.adminCourse(courseId)),
              headers: await _authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return CourseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

// Extension to add assignment methods (avoids touching the original class body)
extension AssignmentApiMethods on ApiManager {
  // ─── ADMIN — ASSIGNMENTS ──────────────────────────────────────────────────

  /// GET /admin/assignments — returns all assignments
  Future<List<AssignmentModel>> getAssignments() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminAssignments),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /admin/assignments — create a new assignment
  Future<AssignmentModel> createAssignment({
    required String courseId,
    required String teacherId,
    required String section,
  }) async {
    try {
      final body = {
        'course_id': courseId,
        'teacher_id': teacherId,
        'section': section,
      };
      final response = await http
          .post(Uri.parse(Endpoints.adminAssignments),
              headers: await _authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return AssignmentModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /admin/assignments/{id} — update teacher or section
  Future<AssignmentModel> updateAssignment({
    required String assignmentId,
    String? teacherId,
    String? section,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (teacherId != null) body['teacher_id'] = teacherId;
      if (section != null) body['section'] = section;

      final response = await http
          .put(Uri.parse(Endpoints.adminAssignment(assignmentId)),
              headers: await _authHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      return AssignmentModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /admin/assignments/{id} — remove an assignment (204 No Content)
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      final response = await http
          .delete(Uri.parse(Endpoints.adminAssignment(assignmentId)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 204) return; // success — no body
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Student Management ─────────────────────────────────────────────────────

  /// GET /admin/students/ — all enrolled students as typed models.
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminAllStudents),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /admin/students/{id} — single student.
  Future<StudentModel> getStudentById(String studentId) async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminStudent(studentId)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /admin/students/{id} — update editable fields.
  Future<StudentModel> updateStudent(
    String studentId, {
    required String fullName,
    required String rollNo,
    required String email,
    required int semesterNumber,
    required String section,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(Endpoints.adminStudent(studentId)),
            headers: await _authHeaders(),
            body: jsonEncode({
              'full_name': fullName,
              'roll_no': rollNo,
              'email': email,
              'semester_number': semesterNumber,
              'section': section,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /admin/students/{id} — hard delete a single student.
  Future<void> deleteStudent(String studentId) async {
    try {
      final response = await http
          .delete(Uri.parse(Endpoints.adminStudent(studentId)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /admin/students/bulk-promote — promote list to next semester.
  Future<Map<String, dynamic>> bulkPromoteStudents(
      List<String> studentIds) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.adminStudentsBulkPromote),
            headers: await _authHeaders(),
            body: jsonEncode({'student_ids': studentIds}),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /admin/students/bulk-delete — permanently remove multiple students.
  Future<Map<String, dynamic>> bulkDeleteStudents(
      List<String> studentIds) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.adminStudentsBulkDelete),
            headers: await _authHeaders(),
            body: jsonEncode({'student_ids': studentIds}),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /admin/courses — returns all courses across all semesters
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminCourses), headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Schedule Management ─────────────────────────────────────────────────

  /// GET /admin/assignments/?semester_id=&section= — for schedule dropdowns
  Future<List<AssignmentModel>> getAssignmentsFiltered({
    String? semesterId,
    String? section,
  }) async {
    try {
      final url = Endpoints.adminAssignmentsFiltered(
          semesterId: semesterId, section: section);
      final response = await http
          .get(Uri.parse(url), headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /admin/schedule/ — list all timetables
  Future<List<TimetableFromApi>> getTimetables() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminSchedule),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => TimetableFromApi.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /admin/schedule/{id} — single timetable
  Future<TimetableFromApi> getTimetableById(String id) async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.adminTimetable(id)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return TimetableFromApi.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /admin/schedule/ — create timetable
  Future<TimetableFromApi> createTimetable({
    required String semesterId,
    required String section,
    required String academicSession,
    required List<Map<String, dynamic>> periods,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.adminSchedule),
            headers: await _authHeaders(),
            body: jsonEncode({
              'semester_id': semesterId,
              'section': section,
              'academic_session': academicSession,
              'periods': periods,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return TimetableFromApi.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /admin/schedule/{id}/periods — replace period list
  Future<TimetableFromApi> updateTimetablePeriods({
    required String id,
    required List<Map<String, dynamic>> periods,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Endpoints.adminTimetablePeriods(id)),
            headers: await _authHeaders(),
            body: jsonEncode({'periods': periods}),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return TimetableFromApi.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /admin/schedule/{id}/entries — assign or update a slot
  Future<TimetableFromApi> assignTimetableEntry({
    required String timetableId,
    required String day,
    required String periodId,
    required String assignmentId,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(Endpoints.adminTimetableEntries(timetableId)),
            headers: await _authHeaders(),
            body: jsonEncode({
              'day': day,
              'period_id': periodId,
              'assignment_id': assignmentId,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return TimetableFromApi.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /admin/schedule/{id}/entries — clear a specific slot
  Future<TimetableFromApi> clearTimetableEntry({
    required String timetableId,
    required String day,
    required String periodId,
  }) async {
    try {
      final request = http.Request(
          'DELETE', Uri.parse(Endpoints.adminTimetableEntries(timetableId)));
      final headers = await _authHeaders();
      request.headers.addAll(headers);
      request.body = jsonEncode({'day': day, 'period_id': periodId});
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      _assertSuccess(response);
      return TimetableFromApi.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /admin/schedule/{id} — delete whole timetable
  Future<void> deleteTimetable(String id) async {
    try {
      final response = await http
          .delete(Uri.parse(Endpoints.adminTimetable(id)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── STUDENT: Check Enrollment Window ────────────────────────────────────
  /// GET /api/v1/students/face/enrollment-window
  /// Returns whether the enrollment screen should be shown.
  Future<EnrollmentWindowModel> getEnrollmentWindow() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.enrollmentWindow),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 15));
      _assertSuccess(response);
      return EnrollmentWindowModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ADMIN: Get Enrollment Deadline ──────────────────────────────────────
  /// GET /api/v1/admin/settings/enrollment-deadline
  /// Pre-fills the date picker on the settings screen.
  Future<EnrollmentDeadlineModel> getEnrollmentDeadline() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.enrollmentDeadline),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 15));
      _assertSuccess(response);
      return EnrollmentDeadlineModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ADMIN: Set Enrollment Deadline ──────────────────────────────────────
  /// PUT /api/v1/admin/settings/enrollment-deadline
  /// [deadline] must be formatted as 'YYYY-MM-DD'.
  Future<EnrollmentDeadlineModel> setEnrollmentDeadline(String deadline) async {
    try {
      final response = await http
          .put(
            Uri.parse(Endpoints.enrollmentDeadline),
            headers: await _authHeaders(),
            body: jsonEncode({'enrollment_deadline': deadline}),
          )
          .timeout(const Duration(seconds: 15));
      _assertSuccess(response);
      return EnrollmentDeadlineModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ADMIN: Get Attendance Criteria ───────────────────────────────────────
  /// GET /api/v1/admin/settings/attendance-criteria
  Future<AttendanceCriteriaModel> getAttendanceCriteria() async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.attendanceCriteria),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 15));
      _assertSuccess(response);
      return AttendanceCriteriaModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ADMIN: Set Attendance Criteria ───────────────────────────────────────
  /// PUT /api/v1/admin/settings/attendance-criteria
  Future<AttendanceCriteriaModel> setAttendanceCriteria(int threshold) async {
    try {
      final response = await http
          .put(
            Uri.parse(Endpoints.attendanceCriteria),
            headers: await _authHeaders(),
            body: jsonEncode({'attendance_threshold_percent': threshold}),
          )
          .timeout(const Duration(seconds: 15));
      _assertSuccess(response);
      return AttendanceCriteriaModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

// ── Minimal API Timetable model (deserialized directly from JSON) ─────────────
// Wraps raw JSON parsing — AdminProvider converts this to the UI Timetable model.
class TimetableFromApi {
  final String id;
  final String semesterId;
  final int semesterNumber;
  final String academicSession;
  final String section;
  final List<Map<String, dynamic>> periods;
  final List<Map<String, dynamic>> entries;

  TimetableFromApi({
    required this.id,
    required this.semesterId,
    required this.semesterNumber,
    required this.academicSession,
    required this.section,
    required this.periods,
    required this.entries,
  });

  factory TimetableFromApi.fromJson(Map<String, dynamic> json) =>
      TimetableFromApi(
        id: json['id'] as String,
        semesterId: json['semester_id'] as String,
        semesterNumber: (json['semester_number'] as num).toInt(),
        academicSession: json['academic_session'] as String,
        section: json['section'] as String,
        periods: (json['periods'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        entries: (json['entries'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}

// ── Teacher Session API ────────────────────────────────────────────────────────
extension TeacherSessionApiMethods on ApiManager {
  // ─── 1. GET teacher's active courses ─────────────────────────────────────
  /// GET /teachers/{teacher_id}/courses
  Future<List<TeacherCourseModel>> getTeacherCourses(String teacherId) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.teacherCourses(teacherId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => TeacherCourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 2. GET roster students for a course ────────────────────────────────
  /// GET /teachers/{teacher_id}/courses/{course_id}/students
  Future<List<RosterStudentModel>> getTeacherCourseStudents(
      String teacherId, String courseId) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.teacherCourseStudents(teacherId, courseId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => RosterStudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 3. POST create session ──────────────────────────────────────────────
  /// POST /teachers/sessions
  Future<SessionModel> createSession({
    required String courseId,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'course_id': courseId,
        'start_time': startTime,
        'end_time': endTime,
      };
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherSessions),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return SessionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 4. GET session attendance list ─────────────────────────────────────
  /// GET /teachers/sessions/{session_id}/attendance
  Future<List<AttendanceRecordModel>> getSessionAttendance(
      String sessionId) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.teacherSessionAttendance(sessionId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => AttendanceRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 5. POST mark student present ───────────────────────────────────────
  /// POST /teachers/sessions/{session_id}/attendance
  /// Throws [AuthException] with backend message on 400 duplicate.
  Future<AttendanceRecordModel> markAttendance(
    String sessionId,
    String studentId, {
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> body = {'student_id': studentId};
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherSessionAttendance(sessionId)),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return AttendanceRecordModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 6. DELETE remove attendance (mark absent) ──────────────────────────
  /// POST /teachers/sessions/{session_id}/attendance/leave
  /// Body: student_id, leave_reason (>= 3 chars after trim).
  Future<AttendanceRecordModel> markAttendanceLeave(
    String sessionId,
    String studentId,
    String leaveReason,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherSessionAttendanceLeave(sessionId)),
            headers: await _authHeaders(),
            body: jsonEncode({
              'student_id': studentId,
              'leave_reason': leaveReason.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return AttendanceRecordModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /teachers/sessions/{session_id}/attendance/{student_id}
  /// 204 = success ; 404 = already absent (no-op).
  Future<void> removeAttendance(String sessionId, String studentId) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Endpoints.teacherSessionAttendanceStudent(
                sessionId, studentId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 204 || response.statusCode == 404) return;
      _assertSuccess(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 7. POST stop session ────────────────────────────────────────────────
  /// POST /teachers/sessions/{session_id}/stop → 200 + SessionResponse.
  Future<SessionModel> stopSession(String sessionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherSessionStop(sessionId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return SessionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 8. GET active sessions ──────────────────────────────────────────────
  /// GET /teachers/sessions/active
  Future<List<SessionModel>> getActiveSessions() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.teacherActiveSessions),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── 9. GET teacher schedule (timetable slots) ───────────────────────────
  /// GET /teachers/{teacher_id}/schedule
  ///
  /// Requires EITHER [timetableId] OR both [semesterId] + [section].
  /// Optional [forDate] ("YYYY-MM-DD") filters by weekday.
  Future<List<TeacherScheduleSlotModel>> getTeacherSchedule(
    String teacherId, {
    String? semesterId,
    String? section,
    String? timetableId,
    String? forDate,
  }) async {
    try {
      final params = <String, String>{};
      if (timetableId != null) {
        params['timetable_id'] = timetableId;
      } else {
        if (semesterId != null) params['semester_id'] = semesterId;
        if (section != null) params['section'] = section;
      }
      if (forDate != null) params['for_date'] = forDate;

      final uri = Uri.parse(Endpoints.teacherSchedule(teacherId))
          .replace(queryParameters: params.isEmpty ? null : params);
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) =>
              TeacherScheduleSlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /teachers/{teacher_id}/schedule/all
  /// Optional filters:
  ///   [forDate] -> YYYY-MM-DD (today or specific date)
  ///   [day] -> Mon/Tue/Wed/Thu/Fri...
  Future<List<TeacherScheduleSlotModel>> getTeacherScheduleAll(
    String teacherId, {
    String? forDate,
    String? day,
  }) async {
    try {
      final params = <String, String>{};
      if (forDate != null && forDate.isNotEmpty) params['for_date'] = forDate;
      if (day != null && day.isNotEmpty) params['day'] = day;

      final uri = Uri.parse(Endpoints.teacherScheduleAll(teacherId))
          .replace(queryParameters: params.isEmpty ? null : params);

      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) =>
              TeacherScheduleSlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /teachers/{teacher_id}/profile-summary
  Future<TeacherProfileSummaryModel> getTeacherProfileSummary(
      String teacherId) async {
    try {
      final response = await http
          .get(Uri.parse(Endpoints.teacherProfileSummary(teacherId)),
              headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return TeacherProfileSummaryModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

// ── Reports API ────────────────────────────────────────────────────────────────
extension ReportsApiMethods on ApiManager {
  Future<CourseReportResponse> getCourseReport(
    String courseId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final params = <String, String>{};
      if (startDate != null && startDate.isNotEmpty) {
        params['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        params['end_date'] = endDate;
      }
      final uri = Uri.parse(Endpoints.reportCourse(courseId))
          .replace(queryParameters: params.isEmpty ? null : params);
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return CourseReportResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MonthlyReportResponse> getMonthlyReport(
    String courseId, {
    required int year,
    required int month,
  }) async {
    try {
      final uri = Uri.parse(Endpoints.reportCourseMonthly(courseId)).replace(
        queryParameters: {
          'year': year.toString(),
          'month': month.toString(),
        },
      );
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return MonthlyReportResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DailyReportResponse> getDailyReport(
    String courseId, {
    required String reportDate,
  }) async {
    try {
      final uri = Uri.parse(Endpoints.reportCourseDaily(courseId)).replace(
        queryParameters: {'report_date': reportDate},
      );
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return DailyReportResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<LowAttendanceStudent>> getLowAttendanceAlerts({
    required String courseId,
    double? threshold,
  }) async {
    try {
      final params = <String, String>{'course_id': courseId};
      if (threshold != null) params['threshold'] = threshold.toString();

      final uri = Uri.parse(Endpoints.reportLowAttendance)
          .replace(queryParameters: params);
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => LowAttendanceStudent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

extension StudentReportsApiMethods on ApiManager {
  /// Global minimum attendance % (same as admin-configured threshold).
  Future<StudentAttendanceCriteriaSettings> getStudentAttendanceCriteria() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentSettingsAttendanceCriteria),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentAttendanceCriteriaSettings.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<StudentMonthPickerBounds> getStudentHistoryMonthBounds() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentReportsHistoryMonthBounds),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentMonthPickerBounds.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<StudentAttendanceHistoryResponse> getStudentAttendanceHistory({
    required int year,
    required int month,
    String? courseId,
    String? date,
  }) async {
    try {
      final uri = Uri.parse(Endpoints.studentReportsHistory(
        year: year,
        month: month,
        courseId: courseId,
        date: date,
      ));
      final response = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentAttendanceHistoryResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<StudentAttendanceSessionRecord> getStudentSessionDetail(
      String sessionId) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentReportsSession(sessionId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentAttendanceSessionRecord.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<StudentSubjectsResponse> getStudentSubjectsReport() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentReportsSubjects),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentSubjectsResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<StudentSubjectDetailResponse> getStudentSubjectDetail(
      String courseId) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentReportsSubjectDetail(courseId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return StudentSubjectDetailResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Semester timetable for the logged-in student.
  /// [400] → section/semester issue; [404] → not published.
  Future<StudentTimetableResponse> getStudentSchedule() async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentSchedule),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 400) {
        throw AuthException('Contact admin to set your section.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Timetable not published yet.');
      }
      _assertSuccess(response);
      return StudentTimetableResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

extension ComplaintsApiMethods on ApiManager {
  List<ComplaintItem> _parseComplaintListBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .map((e) => ComplaintItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ComplaintItem> postStudentAttendanceComplaint({
    required String sessionId,
    required String reason,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.studentComplaints),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'session_id': sessionId,
              'reason': reason,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> postStudentAdminComplaint({
    required String category,
    required String reason,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.studentComplaintsAdmin),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'category': category,
              'reason': reason,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComplaintItem>> getStudentComplaintsAll({String? status}) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.studentComplaintsAll(status: status)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return _parseComplaintListBody(response.body);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Teacher-approved + admin-resolved (two requests, deduped).
  Future<List<ComplaintItem>> getStudentComplaintsResolvedMerged() async {
    final approved = await getStudentComplaintsAll(status: 'approved');
    final resolved = await getStudentComplaintsAll(status: 'resolved');
    final byId = <String, ComplaintItem>{};
    for (final c in [...approved, ...resolved]) {
      byId[c.id] = c;
    }
    final out = byId.values.toList();
    out.sort((a, b) {
      final ta = a.createdAtRaw ?? '';
      final tb = b.createdAtRaw ?? '';
      return tb.compareTo(ta);
    });
    return out;
  }

  Future<List<ComplaintItem>> getTeacherComplaintsInbox({String? status}) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.teacherComplaintsInbox(status: status)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return _parseComplaintListBody(response.body);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Teacher → admin complaints filed by the logged-in teacher.
  Future<List<ComplaintItem>> getTeacherComplaintsSubmitted({String? status}) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.teacherComplaintsSubmitted(status: status)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return _parseComplaintListBody(response.body);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> postTeacherComplaintApprove(
    String complaintId, {
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (notes != null && notes.trim().isNotEmpty) {
        body['notes'] = notes.trim();
      }
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherComplaintApprove(complaintId)),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> postTeacherComplaintReject(
    String complaintId, {
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (notes != null && notes.trim().isNotEmpty) {
        body['notes'] = notes.trim();
      }
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherComplaintReject(complaintId)),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> postTeacherAdminComplaint({
    required String category,
    required String reason,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoints.teacherComplaintsAdmin),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'category': category,
              'reason': reason,
            }),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComplaintItem>> getAdminComplaints({
    String? status,
    String? category,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.adminComplaints(
              status: status,
              category: category,
            )),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return _parseComplaintListBody(response.body);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> getAdminComplaint(String complaintId) async {
    try {
      final response = await http
          .get(
            Uri.parse(Endpoints.adminComplaint(complaintId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> postAdminComplaintResolve(
    String complaintId, {
    String? reviewNotes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (reviewNotes != null && reviewNotes.trim().isNotEmpty) {
        body['review_notes'] = reviewNotes.trim();
      }
      final response = await http
          .post(
            Uri.parse(Endpoints.adminComplaintResolve(complaintId)),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintItem> postAdminComplaintReject(
    String complaintId, {
    String? reviewNotes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (reviewNotes != null && reviewNotes.trim().isNotEmpty) {
        body['review_notes'] = reviewNotes.trim();
      }
      final response = await http
          .post(
            Uri.parse(Endpoints.adminComplaintReject(complaintId)),
            headers: {
              ...await _authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      _assertSuccess(response);
      return ComplaintItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}
