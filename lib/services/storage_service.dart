import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'access_token';
  static const _emailKey = 'user_email';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _userNameKey = 'user_full_name';

  // --- Token ---
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- User Info ---
  static Future<void> saveUserInfo({
    required String email,
    required String userId,
    required String role,
    required String fullName,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userRoleKey, value: role);
    await _storage.write(key: _userNameKey, value: fullName);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  static Future<String?> getUserFullName() async {
    return await _storage.read(key: _userNameKey);
  }

  // --- Clear All (Logout) ---
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
