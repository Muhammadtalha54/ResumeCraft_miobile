import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<Map<String, dynamic>> register({required String name, required String email, required String password});
  Future<UserEntity> verifyEmail({required String email, required String otpCode});
  Future<void> resendVerificationOtp({required String email});
  Future<void> forgotPassword({required String email});
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}
