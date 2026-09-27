import 'package:dio/dio.dart';

import 'failure.dart';

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with ApiServer');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');
      case DioExceptionType.badCertificate:
        return ServerFailure('Bad Certificate with ApiServer');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was canceled');
      case DioExceptionType.connectionError:
        return ServerFailure('No Internet Connection');
      case DioExceptionType.unknown:
        if (dioError.message != null &&
            dioError.message!.contains('SocketException')) {
          return ServerFailure('No Internet Connection');
        }
        return ServerFailure(
          dioError.error?.toString() ??
              dioError.message ??
              'Unexpected Error, Please try again!',
        );
      default:
        return ServerFailure('Oops, there was an error, try again');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      if (response is Map<String, dynamic>) {
        return ServerFailure(
          response['status_message'] ??
              response['message'] ??
              response['error']?['message'] ??
              'Unauthorized / Bad Request',
        );
      }
      return ServerFailure('Unauthorized request, please check your token.');
    } else if (statusCode == 404) {
      return ServerFailure(
        'Your request was not found, please try again later!',
      );
    } else if (statusCode == 500) {
      return ServerFailure('Internal server error, please try again later!');
    } else {
      return ServerFailure('Oops, there was an error, please try again');
    }
  }
}
