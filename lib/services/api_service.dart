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

  static const String _baseUrl = 'http://127.0.0.1:8000';
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
}
