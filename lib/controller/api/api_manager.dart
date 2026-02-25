import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:facialtrackapp/controller/api/endpoints.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─── Custom Exception ─────────────────────────────────────────────────────────
// Named AuthException so every existing `on AuthException catch` block works.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

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
      return AuthException('Connection timed out. Please check your internet.');
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
          .timeout(const Duration(seconds: 10));

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
          .timeout(const Duration(seconds: 10));

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
          .timeout(const Duration(seconds: 10));

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
          .timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));

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

  // ─── 9. GET CURRENT USER (Me) ────────────────────────────────────────────
  Future<UserModel> getMe() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Endpoints.baseUrl}/api/v1/auth/me'),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));

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
          .timeout(const Duration(seconds: 10));
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
          .get(Uri.parse(Endpoints.adminTeachers), headers: await _authHeaders())
          .timeout(const Duration(seconds: 10));

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
          .timeout(const Duration(seconds: 10));

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
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);
      return UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleError(e);
    }
  }
}
