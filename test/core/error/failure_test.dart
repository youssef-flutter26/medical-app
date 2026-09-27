import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/failure.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/error/server_failure.dart';

void main() {
  group('FirebaseFailure tests', () {
    test('handles common Auth error codes', () {
      final failure = FirebaseFailure.fromException(
        FirebaseAuthException(code: 'user-not-found'),
      );
      expect(failure.message, 'Invalid email or password.');
    });

    test('handles email-already-in-use', () {
      final failure = FirebaseFailure.fromException(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(failure.message, 'This email is already in use.');
    });

    test('handles common Firestore error codes', () {
      final failure = FirebaseFailure.fromException(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      expect(
        failure.message,
        'You do not have permission to perform this action.',
      );
    });

    test('handles fallback for unknown code', () {
      final failure = FirebaseFailure.fromException(
        FirebaseAuthException(code: 'unknown-code-xyz'),
      );
      expect(failure.message, 'Authentication failed. Please try again.');
    });
  });

  group('ServerFailure tests', () {
    test('ServerFailure fromDioError handles connection timeout', () {
      final failure = ServerFailure.fromDioError(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(failure.message, 'Connection timeout with ApiServer');
    });

    test('ServerFailure fromResponse handles 404', () {
      final failure = ServerFailure.fromResponse(404, null);
      expect(
        failure.message,
        'Your request was not found, please try again later!',
      );
    });

    test('ServerFailure fromResponse handles 500', () {
      final failure = ServerFailure.fromResponse(500, null);
      expect(failure.message, 'Internal server error, please try again later!');
    });
  });

  group('Failure & Result tests', () {
    test('SuccessAPI holds data correctly', () {
      const result = SuccessAPI<String>('ok');
      expect(result.data, 'ok');
    });

    test('ErrorAPI holds FirebaseFailure correctly', () {
      final failure = FirebaseFailure('Some error');
      final result = ErrorAPI<String>(failure);
      expect(result.failure, isA<Failure>());
      expect(result.failure.message, 'Some error');
    });

    test('ErrorAPI holds ServerFailure correctly', () {
      final failure = ServerFailure('Server error');
      final result = ErrorAPI<String>(failure);
      expect(result.failure, isA<Failure>());
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure.message, 'Server error');
    });
  });
}
