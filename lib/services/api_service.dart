import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Singleton pattern for easy access
  static final ApiService instance = ApiService._internal();

  late final Dio _dio;

  // Base URL (Change this to match your local backend address)
  // For Android Emulator use: 'http://10.0.2.2:8000'
  // For iOS Simulator use: 'http://127.0.0.1:8000'
  // For Linux Desktop use: 'http://127.0.0.1:8000' or 'http://localhost:8000'
  static const String _baseUrl = 'http://127.0.0.1:8000';

  factory ApiService() {
    return instance;
  }

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

    // Add interceptors for logging (optional but helpful)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  // --- Auth Endpoints ---

  Future<Response> loginStudent(String studentId, String password) async {
    try {
      final response = await _dio.post('/auth/student/login', data: {
        'student_id': studentId,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> loginTeacher(String email, String password) async {
    try {
      final response = await _dio.post('/auth/teacher/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> loginAdmin(String email, String password) async {
    try {
      final response = await _dio.post('/auth/admin/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // --- Student Endpoints ---

  Future<Response> registerStudent(Map<String, dynamic> studentData) async {
    try {
      // Assuming endpoint is /students/register or similar
      final response = await _dio.post('/students/register', data: studentData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Example for Attendance
  Future<Response> markAttendance(
      String studentId, String courseId, String imageBase64) async {
    try {
      final response = await _dio.post('/attendance/mark', data: {
        'student_id': studentId,
        'course_id': courseId,
        'image': imageBase64, // simplified for now
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
