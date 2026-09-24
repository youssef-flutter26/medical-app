abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  final int? statusCode;
  final String? responseBody;

  const ServerException({
    this.statusCode,
    this.responseBody,
    String message = 'Server error occurred',
  }) : super(message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to parse response']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}
