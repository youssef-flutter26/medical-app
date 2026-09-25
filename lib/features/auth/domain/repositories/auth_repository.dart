import 'package:medical_app/core/error/result.dart';

import '../../data/models/google_login_result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<GoogleLoginResult>> loginWithGoogle();

  Future<Result<UserEntity>> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<void>> sendEmailVerification();

  Future<Result<bool>> checkEmailVerified();

  Future<Result<bool>> isNameTaken({
    required String name,
  });

  Future<Result<void>> saveUserProfile({
    required String name,
    required String nickname,
    required String email,
    required String birthDate,
    required String gender,
  });

  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Result<void>> logout();
}