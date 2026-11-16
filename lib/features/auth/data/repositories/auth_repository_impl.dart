import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  AuthRepositoryImpl(this._apiClient, this._authStorage);

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );

    final user = UserModel.fromJson(response['user']);
    final accessToken = response['accessToken']?.toString() ?? '';
    final refreshToken = response['refreshToken']?.toString();

    await _authStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await _authStorage.saveUserSession(
      userId: user.id,
      userJson: jsonEncode(user.toJson()),
    );

    return user;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    return {
      'success': response['success'] == true,
      'requiresVerification': response['requiresVerification'] == true,
      'message': response['message']?.toString() ?? 'Registration successful.',
      'email': response['email']?.toString() ?? email.trim(),
    };
  }

  @override
  Future<UserEntity> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyEmail,
      data: {
        'email': email.trim(),
        'otpCode': otpCode.trim(),
      },
    );

    final user = UserModel.fromJson(response['user']);
    final accessToken = response['accessToken']?.toString() ?? '';
    final refreshToken = response['refreshToken']?.toString();

    await _authStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await _authStorage.saveUserSession(
      userId: user.id,
      userJson: jsonEncode(user.toJson()),
    );

    return user;
  }

  @override
  Future<void> resendVerificationOtp({required String email}) async {
    await _apiClient.post(
      ApiEndpoints.resendVerificationOtp,
      data: {'email': email.trim()},
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  @override
  Future<UserEntity?> getCurrentUser({bool forceRefresh = false}) async {
    final token = await _authStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    if (!forceRefresh) {
      final cachedJson = await _authStorage.getUserJson();
      if (cachedJson != null) {
        try {
          return UserModel.fromJson(jsonDecode(cachedJson));
        } catch (_) {}
      }
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      if (response != null && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);
        await _authStorage.saveUserSession(
          userId: user.id,
          userJson: jsonEncode(user.toJson()),
        );
        return user;
      }
    } catch (_) {
      final cachedJson = await _authStorage.getUserJson();
      if (cachedJson != null) {
        try {
          return UserModel.fromJson(jsonDecode(cachedJson));
        } catch (_) {}
      }
    }
    return null;
  }

  @override
  Future<void> saveCachedUser(UserEntity user) async {
    try {
      final model = user is UserModel
          ? user
          : UserModel(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role,
              plan: user.plan,
              status: user.status,
              resumeCredits: user.resumeCredits,
              atsCredits: user.atsCredits,
              profileImage: user.profileImage,
            );
      await _authStorage.saveUserSession(
        userId: user.id,
        userJson: jsonEncode(model.toJson()),
      );
    } catch (_) {}
  }

  @override
  Future<void> logout() async {
    await _authStorage.clearAuth();
  }
}
