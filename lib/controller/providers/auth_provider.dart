import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';

/// Manages all authentication state:
/// login, register, OTP verification, forgot/reset password, logout.
///
/// Screens that use this provider (to be wired in Subtask 4):
///   - Student Login / Teacher Login / Admin Login
///   - Student Signup
///   - OTP Screen / OTP Verification
///   - Forgot Password / Reset Password
class AuthProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Methods (to be fully implemented in Subtask 4) ─────────────────────────

  /// Registers a new user (student or teacher).
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? rollNumber,
    String? department,
    String? semester,
    String? section,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        rollNumber: rollNumber,
        department: department,
        semester: semester,
        section: section,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Verifies the OTP sent after registration.
  Future<bool> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await _api.verifyOtp(email: email, otpCode: otpCode);
      if (data['user'] != null) {
        _currentUser = UserModel.fromJson(data['user']);
      }
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Resends OTP for registration flow.
  Future<bool> resendOtp({required String email}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.resendOtp(email: email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Logs in a user (Student / Teacher / Admin — unified endpoint).
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await _api.login(email: email, password: password);
      if (data['user'] != null) {
        _currentUser = UserModel.fromJson(data['user']);
      }
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Sends a forgot-password OTP to the given email.
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.forgotPassword(email: email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Validates the reset-password OTP (does NOT consume it).
  Future<bool> verifyResetOtp({
    required String email,
    required String otpCode,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.verifyResetOtp(email: email, otpCode: otpCode);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Resends OTP for forgot-password flow.
  Future<bool> resendResetOtp({required String email}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.resendResetOtp(email: email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Sets a new password (consumes the OTP).
  Future<bool> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.resetPassword(
          email: email, otpCode: otpCode, newPassword: newPassword);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Changes password for the currently logged-in user.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.changePassword(
          oldPassword: oldPassword, newPassword: newPassword);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Clears all stored tokens and user state (logout).
  Future<void> logout() async {
    await StorageService.clearAll();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
