import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/app_exception.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl(this.firebaseAuth);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException();
    }
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException();
      }

      await user.updateDisplayName(name);

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (_) {
      throw const AuthException();
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password';

      case 'invalid-email':
        return 'Invalid email address';

      case 'user-disabled':
        return 'This account has been disabled';

      case 'email-already-in-use':
        return 'This email is already in use';

      case 'weak-password':
        return 'Password is too weak';

      case 'operation-not-allowed':
        return 'Email and password authentication is not enabled';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later';

      default:
        return exception.message ?? 'Authentication failed';
    }
  }
}