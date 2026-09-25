import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/app_exception.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl(this.firebaseAuth);

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(
      serverClientId:
          '445898493273-aij0vhb3h9s9c7t4jbqvh8mdahnfn7pl.apps.googleusercontent.com',
    );

    _googleInitialized = true;
  }

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
  Future<User> loginWithGoogle() async {
    try {
      debugPrint('========== GOOGLE SIGN-IN START ==========');

      await _initializeGoogleSignIn();

      debugPrint('GOOGLE SIGN-IN INITIALIZED');

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      debugPrint('GOOGLE ACCOUNT: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      debugPrint('GOOGLE ID TOKEN: ${googleAuth.idToken != null}');

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const AuthException();
      }

      debugPrint('FIREBASE USER: ${user.email}');
      debugPrint('========== GOOGLE SIGN-IN SUCCESS ==========');

      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('========== FIREBASE GOOGLE ERROR ==========');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      debugPrint('StackTrace: $stackTrace');

      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('========== GOOGLE SIGN-IN ERROR ==========');
      debugPrint('Exception: $e');
      debugPrint('StackTrace: $stackTrace');

      throw AuthException(e.toString());
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
      await _googleSignIn.signOut();
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