import 'package:firebase_auth/firebase_auth.dart';

import 'failure.dart';

class FirebaseFailure extends Failure {
  FirebaseFailure(super.message);

  factory FirebaseFailure.fromException(Object error) {
    if (error is FirebaseAuthException) {
      return FirebaseFailure(_getAuthMessage(error.code));
    }

    if (error is FirebaseException) {
      final base = _getFirebaseMessage(error.code);
      final msg = error.message;
      return FirebaseFailure(
        msg != null && msg.isNotEmpty ? '$base ($msg)' : base,
      );
    }

    return FirebaseFailure('Something went wrong. Please try again.');
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

      case 'not-found':
        return 'The requested data was not found.';

      case 'already-exists':
        return 'The data already exists.';

      case 'unavailable':
        return 'The service is temporarily unavailable.';

      case 'unauthenticated':
        return 'Please sign in again.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
