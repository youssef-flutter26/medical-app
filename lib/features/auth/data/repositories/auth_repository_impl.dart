import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/firebase_failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/server_failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/google_login_result.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.userRemoteDataSource);

  static const String _adminEmail = 'mrnon3432@gmail.com';
  static const String _adminName = 'Admin';

  bool _isAdminEmail(String? email) {
    if (email == null) return false;
    return email.trim().toLowerCase() == _adminEmail;
  }

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

      final existingUser = await userRemoteDataSource.getUser(user.uid);
      final isAdmin = _isAdminEmail(user.email ?? email);
      final assignedRole = isAdmin ? 'admin' : (existingUser?.role ?? 'user');
      final assignedName = isAdmin
          ? (existingUser?.name?.trim().isNotEmpty == true
              ? existingUser!.name!
              : _adminName)
          : (existingUser?.name ?? user.displayName);

      final userModel = UserModel.fromFirebase(
        id: user.uid,
        email: user.email ?? email,
        name: assignedName,
        nickname: existingUser?.nickname,
        birthDate: existingUser?.birthDate,
        gender: existingUser?.gender,
        role: assignedRole,
      );

      if (existingUser == null || (isAdmin && existingUser.role != 'admin')) {
        await userRemoteDataSource.saveUser(userModel);
      }

      return SuccessAPI(userModel);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Result<GoogleLoginResult>> loginWithGoogle() async {
    try {
      final user = await remoteDataSource.loginWithGoogle();

      final existingUser = await userRemoteDataSource.getUser(user.uid);
      final isAdmin = _isAdminEmail(user.email);
      final assignedRole = isAdmin ? 'admin' : (existingUser?.role ?? 'user');
      final assignedName = isAdmin
          ? (existingUser?.name?.trim().isNotEmpty == true
              ? existingUser!.name!
              : _adminName)
          : (existingUser?.name ?? user.displayName);

      if (existingUser != null) {
        if (isAdmin && existingUser.role != 'admin') {
          final updatedAdmin = UserModel.fromFirebase(
            id: user.uid,
            email: user.email ?? '',
            name: assignedName,
            nickname: existingUser.nickname,
            birthDate: existingUser.birthDate,
            gender: existingUser.gender,
            role: 'admin',
          );
          await userRemoteDataSource.saveUser(updatedAdmin);
          return SuccessAPI(
            GoogleLoginResult(user: updatedAdmin, isNewUser: false),
          );
        }

        return SuccessAPI(
          GoogleLoginResult(user: existingUser, isNewUser: false),
        );
      }

      final userModel = UserModel.fromFirebase(
        id: user.uid,
        email: user.email ?? '',
        name: assignedName,
        role: assignedRole,
      );

      await userRemoteDataSource.saveUser(userModel);

      return SuccessAPI(GoogleLoginResult(user: userModel, isNewUser: true));
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } on NetworkException catch (_) {
      return ErrorAPI(FirebaseFailure('No internet connection.'));
    } on ServerException catch (e) {
      return ErrorAPI(ServerFailure(e.message));
    } on ParsingException catch (_) {
      return ErrorAPI(ServerFailure('Failed to parse response.'));
    } catch (_) {
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
      );
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

      final firebaseAuthUser = FirebaseAuth.instance.currentUser ?? user;

      final isAdmin = _isAdminEmail(firebaseAuthUser.email ?? email);
      final assignedRole = isAdmin ? 'admin' : 'user';
      final assignedName = isAdmin
          ? (name.trim().isNotEmpty ? name.trim() : _adminName)
          : name;

      final userModel = UserModel.fromFirebase(
        id: firebaseAuthUser.uid,
        email: firebaseAuthUser.email ?? email,
        name: assignedName,
        role: assignedRole,
      );

      // Create users/{uid} document in Firestore immediately after auth
      await userRemoteDataSource.saveUser(userModel);

      return SuccessAPI(userModel);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore/Firebase error during signup: [${e.code}] ${e.message}',
      );
      return ErrorAPI(FirebaseFailure.fromException(e));
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      return ErrorAPI(FirebaseFailure.fromException(e));
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
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Result<bool>> checkEmailVerified() async {
    try {
      final verified = await remoteDataSource.checkEmailVerified();

      return SuccessAPI(verified);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Result<bool>> isNameTaken({required String name}) async {
    try {
      final isTaken = await remoteDataSource.isNameTaken(name);

      return SuccessAPI(isTaken);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);

      return const SuccessAPI(null);
    } on FirebaseAuthException catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    } catch (e) {
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
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
        return ErrorAPI(FirebaseFailure('No authenticated user found.'));
      }

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        return ErrorAPI(FirebaseFailure('No authenticated user found.'));
      }

      if (!refreshedUser.emailVerified) {
        return ErrorAPI(
          FirebaseFailure(
            'Please verify your email address before saving your profile.',
          ),
        );
      }

      final existingUser = await userRemoteDataSource.getUser(refreshedUser.uid);
      final isAdmin = _isAdminEmail(refreshedUser.email ?? email) ||
          existingUser?.role == 'admin';
      final role = isAdmin ? 'admin' : (existingUser?.role ?? 'user');
      final assignedName = isAdmin && name.trim().isEmpty
          ? _adminName
          : (name.isNotEmpty
              ? name
              : (existingUser?.name ?? refreshedUser.displayName));

      final userModel = UserModel(
        id: refreshedUser.uid,
        email: email.isNotEmpty ? email : (refreshedUser.email ?? ''),
        name: assignedName,
        nickname:
            nickname.trim().isEmpty ? existingUser?.nickname : nickname.trim(),
        birthDate: birthDate.trim().isEmpty
            ? existingUser?.birthDate
            : birthDate.trim(),
        gender: gender.trim().isEmpty ? existingUser?.gender : gender.trim(),
        role: role,
      );

      await userRemoteDataSource.saveUser(userModel);

      if (name.isNotEmpty && name != refreshedUser.displayName) {
        try {
          await refreshedUser.updateDisplayName(name);
        } catch (_) {}
      }

      return const SuccessAPI(null);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
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
      return ErrorAPI(
        FirebaseFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Result<UserEntity?>> getUserProfile(String uid) async {
    try {
      final user = await userRemoteDataSource.getUser(uid);
      return SuccessAPI(user);
    } catch (_) {
      return ErrorAPI(
        FirebaseFailure('Failed to load user profile.'),
      );
    }
  }

  Failure _mapAuthException(AuthException exception) {
    return FirebaseFailure(
      exception.message.isNotEmpty
          ? exception.message
          : 'Authentication failed. Please try again.',
    );
  }
}
