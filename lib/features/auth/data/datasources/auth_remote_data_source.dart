import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthRemoteDataSource {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();
}