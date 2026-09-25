import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/app_exception.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  AuthRemoteDataSourceImpl(this.firebaseAuth);

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

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
        throw const AuthException(
          'Unable to login. Please try again.',
        );
      }

      await user.reload();

      final refreshedUser = firebaseAuth.currentUser;

      if (refreshedUser == null) {
        throw const AuthException(
          'Unable to login. Please try again.',
        );
      }

      if (!refreshedUser.emailVerified) {
        await firebaseAuth.signOut();

        throw const AuthException(
          'Please verify your email address before signing in.',
        );
      }

      return refreshedUser;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Unable to login. Please try again.',
      );
    }
  }

  @override
  Future<User> loginWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          'Unable to sign in with Google.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Unable to sign in with Google.',
      );
    }
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential =
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          'Unable to create account.',
        );
      }

      await user.updateDisplayName(name);

      await user.sendEmailVerification();

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final existingUser = await _loginExistingUnverifiedUser(
          email: email,
          password: password,
        );

        if (existingUser != null) {
          await existingUser.delete();

          await firebaseAuth.signOut();

          final newCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          final newUser = newCredential.user;

          if (newUser == null) {
            throw const AuthException(
              'Unable to create account.',
            );
          }

          await newUser.updateDisplayName(name);

          await newUser.sendEmailVerification();

          return newUser;
        }
      }

      throw _mapFirebaseAuthError(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Unable to create account.',
      );
    }
  }

  Future<User?> _loginExistingUnverifiedUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return null;
      }

      await user.reload();

      final refreshedUser = firebaseAuth.currentUser;

      if (refreshedUser == null) {
        return null;
      }

      if (refreshedUser.emailVerified) {
        await firebaseAuth.signOut();
        return null;
      }

      return refreshedUser;
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthException(
          'No authenticated user found.',
        );
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Unable to send verification email.',
      );
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        return false;
      }

      await user.reload();

      final refreshedUser = firebaseAuth.currentUser;

      return refreshedUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isNameTaken(String name) async {
    final normalizedName = name.trim().toLowerCase();

    final snapshot = await firestore
        .collection('users')
        .where('nameLowercase', isEqualTo: normalizedName)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<User?> getCurrentUser() async {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {
      throw const AuthException(
        'Unable to logout. Please try again.',
      );
    }
  }

  AuthException _mapFirebaseAuthError(FirebaseAuthException e,) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      return const AuthException(
        'Invalid email or password.',
      );

      case 'invalid-email':
        return const AuthException(
          'Please enter a valid email address.',
        );

      case 'user-disabled':
        return const AuthException(
          'This account has been disabled.',
        );

      case 'email-already-in-use':
        return const AuthException(
          'This email is already in use.',
        );

      case 'weak-password':
        return const AuthException(
          'The password is too weak.',
        );

      case 'operation-not-allowed':
        return const AuthException(
          'This sign-in method is not enabled.',
        );

      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please try again later.',
        );

      default:
        return AuthException(
          e.message ?? 'Authentication failed. Please try again.',
        );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(
      email: email,
    );
  }
}