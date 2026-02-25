import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:flutter/foundation.dart';

/// Manages student-specific state.
///
/// Used by:
///   - StudentWaitingApprovalScreen  (checkApprovalStatus)
///   - StudentProfileScreen          (fetchProfile / studentProfile)
///   - DashboardScreen               (studentProfile for name banner)
class StudentProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _studentProfile;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get studentProfile => _studentProfile;

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

  // ── Methods ────────────────────────────────────────────────────────────────

  /// Fetches the current student's full profile from the API and caches it.
  /// Returns true on success.
  Future<bool> fetchProfile() async {
    _setLoading(true);
    _setError(null);
    try {
      _studentProfile = await _api.getMe();
      notifyListeners();
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

  /// Silently polls /me to check approval status.
  /// Returns the fresh [UserModel] on success, null on failure (so screens
  /// can keep polling without disrupting the UI).
  Future<UserModel?> checkApprovalStatus() async {
    try {
      final user = await _api.getMe();
      _studentProfile = user;
      notifyListeners();
      return user;
    } on AuthException {
      // Token may have expired — caller should stop polling
      return null;
    } catch (_) {
      // Network glitch — caller should keep polling
      return null;
    }
  }

  /// Resets provider state (call on logout).
  void clear() {
    _studentProfile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
