import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:facialtrackapp/controller/api/endpoints.dart';
import 'package:facialtrackapp/core/models/enrollment_config_model.dart';
import 'package:facialtrackapp/core/models/face_status_model.dart';
import 'package:facialtrackapp/core/models/frame_analysis_result.dart';
import 'package:facialtrackapp/core/models/pending_student_model.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
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
}
