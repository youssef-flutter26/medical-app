import 'package:easy_localization/easy_localization.dart';
import '../localization/locale_keys.dart';

sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, String message = 'Server error'})
    : super(message);

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
    NetworkFailure() => LocaleKeys.pleaseCheckInternet.tr(),
    ServerFailure(statusCode: 404) => LocaleKeys.contentNotFound.tr(),
    ServerFailure(statusCode: 500) => LocaleKeys.serverIssues.tr(),
    ServerFailure() => LocaleKeys.serverError.tr(),
    ParsingFailure() => LocaleKeys.unexpectedFormat.tr(),
    AuthFailure() => message,
    UnknownFailure() => message,
  };
}
