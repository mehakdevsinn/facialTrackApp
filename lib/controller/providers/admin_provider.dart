import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:flutter/foundation.dart';

/// Manages all admin-specific state.
///
/// Screens that use this provider (to be wired in Subtask 7):
///   - Admin Dashboard
///   - Manage Teachers (list, create, update)
///   - User Approval
///   - Admin Profile
class AdminProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  // Teacher management state
  List<UserModel> _teachers = [];
  bool _isTeachersLoading = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserModel> get teachers => List.unmodifiable(_teachers);
  bool get isTeachersLoading => _isTeachersLoading;

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

  // ── Methods (to be fully implemented in Subtask 7) ─────────────────────────

  /// Fetches all teachers from the API.
  Future<void> fetchTeachers() async {
    _isTeachersLoading = true;
    _setError(null);
    notifyListeners();
    try {
      _teachers = await _api.getAllTeachers();
      _isTeachersLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
      _isTeachersLoading = false;
      notifyListeners();
    } catch (_) {
      _setError('An unexpected error occurred.');
      _isTeachersLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new teacher account and refreshes the list on success.
  Future<bool> createTeacher({
    required String email,
    required String fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newTeacher = await _api.createTeacher(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        designation: designation,
        qualification: qualification,
      );
      _teachers = [newTeacher, ..._teachers];
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

  /// Updates an existing teacher's details and refreshes the list entry.
  Future<bool> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _api.updateTeacher(
        teacherId: teacherId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        designation: designation,
        qualification: qualification,
      );
      // Replace the stale entry in the list
      _teachers =
          _teachers.map((t) => t.id == teacherId ? updated : t).toList();
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

  /// Resets provider state (call on logout).
  void clear() {
    _teachers = [];
    _errorMessage = null;
    _isLoading = false;
    _isTeachersLoading = false;
    notifyListeners();
  }
}
