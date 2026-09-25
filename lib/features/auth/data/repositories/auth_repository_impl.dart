import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/google_login_result.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource,
      this.userRemoteDataSource,);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final userModel = UserModel.fromFirebase(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName,
      );

      return SuccessAPI(userModel);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }

  @override
  Future<Result<GoogleLoginResult>> loginWithGoogle() async {
    try {
      final user = await remoteDataSource.loginWithGoogle();

      final existingUser = await userRemoteDataSource.getUser(user.uid);

      if (existingUser != null) {
        return SuccessAPI(
          GoogleLoginResult(
            user: existingUser,
            isNewUser: false,
          ),
        );
      }

      final userModel = UserModel.fromFirebase(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName,
      );

      await userRemoteDataSource.saveUser(userModel);

      return SuccessAPI(
        GoogleLoginResult(
          user: userModel,
          isNewUser: true,
        ),
      );
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } on NetworkException catch (_) {
      return const ErrorAPI(NetworkFailure());
    } on ServerException catch (e) {
      return ErrorAPI(
        ServerFailure(statusCode: e.statusCode),
      );
    } on ParsingException catch (_) {
      return const ErrorAPI(ParsingFailure());
    } catch (_) {
      return const ErrorAPI(UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await remoteDataSource.signup(
        email: email,
        password: password,
        name: name,
      );

      final userModel = UserModel.fromFirebase(
        id: user.uid,
        email: user.email ?? email,
        name: name,
      );

      // IMPORTANT:
      // Do NOT save the user to Firestore here.
      // The user must verify the email first.
      return SuccessAPI(userModel);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();

      return const SuccessAPI(null);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }


  @override
  Future<Result<bool>> checkEmailVerified() async {
    try {
      final verified =
      await remoteDataSource.checkEmailVerified();

      return SuccessAPI(verified);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }

  @override
  Future<Result<bool>> isNameTaken({
    required String name,
  }) async {
    try {
      final isTaken = await remoteDataSource.isNameTaken(name);

      return SuccessAPI(isTaken);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(
        email: email,
      );

      return const SuccessAPI(null);
    } on FirebaseAuthException catch (e) {
      return ErrorAPI(
        ServerFailure(
          message: e.message ?? 'Failed to send password reset email.',
        ),
      );
    } catch (e) {
      return ErrorAPI(
        ServerFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveUserProfile({
    required String name,
    required String nickname,
    required String email,
    required String birthDate,
    required String gender,
  }) async {
    try {
      final user = await remoteDataSource.getCurrentUser();

      if (user == null) {
        return const ErrorAPI(
          AuthFailure(
            'No authenticated user found.',
          ),
        );
      }

      await user.reload();

      final refreshedUser =
          FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        return const ErrorAPI(
          AuthFailure(
            'No authenticated user found.',
          ),
        );
      }

      if (!refreshedUser.emailVerified) {
        return const ErrorAPI(
          AuthFailure(
            'Please verify your email address before saving your profile.',
          ),
        );
      }

      final userModel = UserModel(
        id: refreshedUser.uid,
        email: email,
        name: name,
        nickname: nickname
            .trim()
            .isEmpty ? null : nickname.trim(),
        birthDate: birthDate
            .trim()
            .isEmpty ? null : birthDate.trim(),
        gender: gender
            .trim()
            .isEmpty ? null : gender.trim(),
      );

      await userRemoteDataSource.saveUser(
        userModel,
      );

      return const SuccessAPI(null);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();

      return const SuccessAPI(null);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(
        UnknownFailure(),
      );
    }
  }

  Failure _mapAuthException(AuthException exception,) {
    return AuthFailure(
      exception.message ??
          'Authentication failed. Please try again.',
    );
  }
}