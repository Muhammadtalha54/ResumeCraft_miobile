import 'package:dio/dio.dart';
import '../errors/app_exceptions.dart';

/// Centralized Dio exception mapper to typed AppExceptions.
class NetworkExceptionMapper {
  NetworkExceptionMapper._();

  static AppException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        String message = 'An unexpected server error occurred.';
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            message = data['message'].toString();
          } else if (data['error'] != null) {
            message = data['error'].toString();
          }

          if (data['code'] == 'USER_BLOCKED') {
            return UserBlockedException(message);
          }
          if (data['code'] == 'EMAIL_NOT_VERIFIED') {
            return EmailNotVerifiedException(message, data['email']?.toString());
          }
        }

        if (statusCode == 401) {
          return UnauthorizedException(message);
        } else if (statusCode == 403) {
          return UserBlockedException(message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message, statusCode);
        } else {
          return ServerException(message, statusCode);
        }

      case DioExceptionType.cancel:
        return const AppException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return const NetworkException('Unable to reach server. Please verify backend is running.');

      default:
        return AppException(error.message ?? 'A network communication error occurred.');
    }
  }
}
