import 'failure.dart';

sealed class Result<T> {
  const Result();
}

class SuccessAPI<T> extends Result<T> {
  const SuccessAPI(this.data);
  final T data;
}

class ErrorAPI<T> extends Result<T> {
  const ErrorAPI(this.failure);
  final Failure failure;
}
