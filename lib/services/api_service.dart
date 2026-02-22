import 'package:dio/dio.dart';
import 'package:facialtrackapp/models/user_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';

// Custom exception for clean error handling across the app
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService instance = ApiService._internal();

  late final Dio _dio;

  static const String _baseUrl = 'https://facialtrackapp.site';
  static const String _authBase = '/api/v1/auth';

  factory ApiService() => instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Log requests/responses only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  // Attach the JWT token to all authenticated requests
  Future<Options> _authHeader() async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Parses Dio errors into clean AuthException messages
  AuthException _handleError(dynamic error) {
    if (kDebugMode) {
      debugPrint('== API ERROR CAUGHT ==');
      debugPrint(error.toString());
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return AuthException(
            'Connection timed out. Please check your internet.');
      }
      if (error.type == DioExceptionType.connectionError) {
        return AuthException(
            'Cannot connect to server. Make sure the backend is running.');
      }
      final detail = error.response?.data?['detail'];
      if (detail != null) {
        return AuthException(detail.toString());
      }
      return AuthException('Network error: ${error.message}');
    }

    // Capture non-network errors (e.g., TypeError, MissingPluginException)
    return AuthException('An unexpected error occurred: ${error.toString()}');
  }

  // ─────────────────────────────────────────────
  // 1. REGISTER
  // POST /api/v1/auth/register
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    // Student-only fields
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

      // Add student-specific fields only if role is student
      if (role == 'student') {
        body['roll_number'] = rollNumber;
        body['department'] = department;
        body['semester'] = semester;
        if (section != null && section.isNotEmpty) {
          body['section'] = section;
        }
      }

      final response = await _dio.post('$_authBase/register', data: body);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 2. VERIFY OTP
  // POST /api/v1/auth/verify-otp
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post('$_authBase/verify-otp', data: {
        'email': email,
        'otp_code': otpCode,
      });

      final data = response.data as Map<String, dynamic>;

      // Save token and user info securely on successful OTP verification
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
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 3. RESEND OTP
  // POST /api/v1/auth/resend-otp
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await _dio.post('$_authBase/resend-otp', data: {
        'email': email,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // Resend OTP — Forgot Password flow
  // POST /api/v1/auth/resend-reset-otp
  // ─────────────────────────────────────────────
  Future<void> resendResetOtp({required String email}) async {
    try {
      await _dio.post('$_authBase/resend-reset-otp', data: {'email': email});
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 6. FORGOT PASSWORD — Request OTP
  // POST /api/v1/auth/forgot-password
  // ─────────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('$_authBase/forgot-password', data: {'email': email});
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 7. VERIFY RESET OTP — Validate OTP (does NOT consume it)
  // POST /api/v1/auth/verify-reset-otp
  // ─────────────────────────────────────────────
  Future<void> verifyResetOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      await _dio.post('$_authBase/verify-reset-otp', data: {
        'email': email,
        'otp_code': otpCode,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 8. RESET PASSWORD — Set new password (consumes OTP)
  // POST /api/v1/auth/reset-password
  // ─────────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await _dio.post('$_authBase/reset-password', data: {
        'email': email,
        'otp_code': otpCode,
        'new_password': newPassword,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 4. LOGIN (unified for Student, Teacher, Admin)
  // POST /api/v1/auth/login
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('$_authBase/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;

      // Save token and user info securely on successful login
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
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 5. GET CURRENT USER (Me)
  // GET /api/v1/auth/me
  // ─────────────────────────────────────────────
  Future<UserModel> getMe() async {
    try {
      final response =
          await _dio.get('$_authBase/me', options: await _authHeader());
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT — clears all stored data
  // ─────────────────────────────────────────────
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // ─────────────────────────────────────────────
  // 9. CHANGE PASSWORD (authenticated)
  // POST /api/v1/auth/change-password
  // ─────────────────────────────────────────────
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '$_authBase/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        options: await _authHeader(),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 10. LIST ALL TEACHERS (Admin)
  // GET /api/v1/admin/teachers/
  // ─────────────────────────────────────────────
  Future<List<UserModel>> getAllTeachers() async {
    try {
      final response = await _dio.get(
        '/api/v1/admin/teachers/',
        options: await _authHeader(),
      );
      final List data = response.data as List;
      return data
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────
  // 11. CREATE TEACHER (Admin)
  // POST /api/v1/admin/teachers/
  // ─────────────────────────────────────────────
  Future<UserModel> createTeacher({
    required String email,
    required String fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'email': email,
        'full_name': fullName,
      };
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }
      if (designation != null && designation.isNotEmpty) {
        body['designation'] = designation;
      }
      if (qualification != null && qualification.isNotEmpty) {
        body['qualification'] = qualification;
      }

      final response = await _dio.post(
        '/api/v1/admin/teachers/',
        data: body,
        options: await _authHeader(),
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
