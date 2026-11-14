import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence adapter using FlutterSecureStorage.
/// Strictly for sensitive authentication credentials (JWTs, session tokens).
class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const String _keyAccessToken = 'rc_access_token';
  static const String _keyRefreshToken = 'rc_refresh_token';
  static const String _keyUserId = 'rc_user_id';
  static const String _keyUserJson = 'rc_user_json';

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserSession({required String userId, required String userJson}) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserJson, value: userJson);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<String?> getUserJson() async {
    return await _storage.read(key: _keyUserJson);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserJson);
  }
}
