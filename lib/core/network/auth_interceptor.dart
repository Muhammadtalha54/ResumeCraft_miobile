import 'package:dio/dio.dart';
import '../storage/auth_storage.dart';
import 'api_endpoints.dart';

/// Interceptor to automatically attach JWT authorization headers and handle token refresh.
class AuthInterceptor extends QueuedInterceptor {
  final AuthStorage _authStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._authStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Exclude public auth endpoints from attaching tokens
    final publicPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.refreshToken,
    ];

    final isPublic = publicPaths.any((path) => options.path.contains(path));

    if (!isPublic) {
      final token = await _authStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    // If 401 Unauthorized occurs on a protected endpoint, attempt silent refresh
    if (response?.statusCode == 401 && !err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await _authStorage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            // Call refresh token endpoint directly
            final refreshResponse = await _dio.post(
              ApiEndpoints.refreshToken,
              data: {'refreshToken': refreshToken},
            );

            if (refreshResponse.statusCode == 200 && refreshResponse.data['accessToken'] != null) {
              final newAccessToken = refreshResponse.data['accessToken'].toString();
              await _authStorage.saveTokens(accessToken: newAccessToken);

              // Retry original request with new access token
              err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(err.requestOptions);
              _isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          }
        } catch (refreshErr) {
          // Token refresh failed - invalidate session
          await _authStorage.clearAuth();
        } finally {
          _isRefreshing = false;
        }
      }
    }

    return handler.next(err);
  }
}
