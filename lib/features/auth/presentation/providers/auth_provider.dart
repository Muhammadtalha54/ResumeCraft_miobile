import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Storage & Client Providers
final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(authStorageProvider);
  return ApiClient(storage);
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(authStorageProvider);
  return AuthRepositoryImpl(client, storage);
});

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthActionResult {
  final bool isSuccess;
  final bool requiresVerification;
  final String? email;
  final String? message;

  const AuthActionResult({
    required this.isSuccess,
    this.requiresVerification = false,
    this.email,
    this.message,
  });

  factory AuthActionResult.success([String? message]) =>
      AuthActionResult(isSuccess: true, message: message);

  factory AuthActionResult.requiresVerification({required String email, String? message}) =>
      AuthActionResult(isSuccess: false, requiresVerification: true, email: email, message: message);

  factory AuthActionResult.failure(String message) =>
      AuthActionResult(isSuccess: false, message: message);
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        // Silently fetch fresh profile and credits in background
        _repository.getCurrentUser(forceRefresh: true).then((fresh) {
          if (fresh != null && mounted) {
            state = state.copyWith(user: fresh);
          }
        });
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final fresh = await _repository.getCurrentUser(forceRefresh: true);
      if (fresh != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: fresh);
      }
    } catch (_) {}
  }

  Future<AuthActionResult> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return AuthActionResult.success();
    } on EmailNotVerifiedException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return AuthActionResult.requiresVerification(
        email: e.email ?? email.trim(),
        message: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return AuthActionResult.failure(e.toString());
    }
  }

  Future<AuthActionResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await _repository.register(name: name, email: email, password: password);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      if (res['requiresVerification'] == true) {
        return AuthActionResult.requiresVerification(
          email: res['email']?.toString() ?? email.trim(),
          message: res['message']?.toString(),
        );
      }
      return AuthActionResult.success(res['message']?.toString());
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return AuthActionResult.failure(e.toString());
    }
  }

  Future<bool> verifyEmail({required String email, required String otpCode}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.verifyEmail(email: email, otpCode: otpCode);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> resendVerificationOtp({required String email}) async {
    try {
      await _repository.resendVerificationOtp(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      await _repository.forgotPassword(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated, user: null);
  }

  void updateCredits({int? atsCredits, int? resumeCredits}) {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        atsCredits: atsCredits,
        resumeCredits: resumeCredits,
      );
      state = state.copyWith(user: updated);
      _repository.saveCachedUser(updated);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
