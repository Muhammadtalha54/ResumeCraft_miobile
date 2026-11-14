/// Application-level exception hierarchy.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Unable to connect to server. Please check your network.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Session expired. Please log in again.'])
      : super(message, 401);
}

class UserBlockedException extends AppException {
  const UserBlockedException([String message = 'Your account has been suspended by an administrator.'])
      : super(message, 403);
}

class EmailNotVerifiedException extends AppException {
  final String? email;
  const EmailNotVerifiedException([String message = 'Please verify your email address to continue.', this.email])
      : super(message, 403);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
