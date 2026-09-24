sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}


class ServerFailure extends Failure {
  const ServerFailure({
    this.statusCode,
    String message = 'Server error',
  }) : super(message);

  final int? statusCode;
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse response']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

extension FailureMessage on Failure {
  String get userMessage => switch (this) {
    NetworkFailure() => 'Please check your internet connection',
    ServerFailure(statusCode: 404) => 'Content not found',
    ServerFailure(statusCode: 500) =>
    'Server is having issues, try again later',
    ServerFailure() => 'Something went wrong on the server',
    ParsingFailure() => 'Unexpected response format',
    AuthFailure() => message,
    UnknownFailure() => message,
  };
}