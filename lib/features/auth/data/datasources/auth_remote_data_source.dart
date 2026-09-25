import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> loginWithGoogle();

  Future<User> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<void> sendEmailVerification();

  Future<bool> checkEmailVerified();

  Future<void> logout();

  Future<bool> isNameTaken(String name);

  Future<User?> getCurrentUser();

  Future<void> sendPasswordResetEmail({
    required String email,
  });
}