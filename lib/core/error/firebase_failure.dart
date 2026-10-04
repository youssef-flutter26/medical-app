import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'failure.dart';

class FirebaseFailure extends Failure {
  FirebaseFailure(super.message);

  factory FirebaseFailure.fromException(Object error) {
    if (error is FirebaseAuthException) {
      debugPrint(
        '[FirebaseFailure] FirebaseAuthException: '
            '[${error.code}] ${error.message}',
      );

      return FirebaseFailure(_getAuthMessage(error.code));
    }

    if (error is FirebaseException) {
      debugPrint(
        '[FirebaseFailure] FirebaseException: '
            '[${error.code}] ${error.message}',
      );

      final base = _getFirebaseMessage(error.code);
      final msg = error.message;

      return FirebaseFailure(
        msg != null && msg.isNotEmpty ? '$base ($msg)' : base,
      );
    }

    debugPrint('[FirebaseFailure] Unknown Exception: $error');

    return FirebaseFailure(
      'Something went wrong. Please try again.',
    );
  }

  static String _getAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'email-already-in-use':
        return 'This email is already in use.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'No internet connection.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _getFirebaseMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';

      case 'unauthenticated':
        return 'Please sign in again.';

      case 'not-found':
        return 'The requested data was not found.';

      case 'already-exists':
        return 'The data already exists.';

      case 'failed-precondition':
        return 'Firebase is not configured correctly for this operation.';

      case 'unavailable':
        return 'The Firebase service is temporarily unavailable.';

      case 'deadline-exceeded':
        return 'The request took too long. Please try again.';

      case 'cancelled':
        return 'The operation was cancelled.';

      case 'aborted':
        return 'The operation was interrupted. Please try again.';

      case 'resource-exhausted':
        return 'Firebase resources are temporarily exhausted.';

      case 'data-loss':
        return 'A data error occurred in Firebase.';

      case 'invalid-argument':
        return 'Some of the entered data is invalid.';

      case 'out-of-range':
        return 'The provided data is out of range.';

      case 'internal':
        return 'An internal Firebase error occurred.';

      case 'unknown':
        return 'An unknown Firebase error occurred.';

      default:
        return 'Firebase error: $code';
    }
  }
}