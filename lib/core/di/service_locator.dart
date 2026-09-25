import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../core/routing/app_router.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/datasources/user_remote_data_source.dart';
import '../../features/auth/data/datasources/user_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_email_verified.dart';
import '../../features/auth/domain/usecases/check_name_availability.dart';
import '../../features/auth/domain/usecases/forgot_password.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/domain/usecases/save_user_profile.dart';
import '../../features/auth/domain/usecases/send_email_verification.dart';
import '../../features/auth/domain/usecases/signup.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<http.Client>(
        () => http.Client(),
  );

  getIt.registerLazySingleton<FirebaseAuth>(
        () => FirebaseAuth.instance,
  );

  getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<AppRouter>(
        () => AppRouter(),
  );

  // Data Sources

  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
        () =>
        UserRemoteDataSourceImpl(
          getIt<FirebaseFirestore>(),
        ),
  );

  // Repository

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
          getIt<UserRemoteDataSource>(),
    ),
  );

  // Use Cases

  getIt.registerLazySingleton<Login>(
        () => Login(
      getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<LoginWithGoogle>(
        () =>
        LoginWithGoogle(
          getIt<AuthRepository>(),
        ),
  );

  getIt.registerLazySingleton<Signup>(
        () => Signup(
      getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<CheckEmailVerified>(
        () =>
        CheckEmailVerified(
          getIt<AuthRepository>(),
        ),
  );

  getIt.registerLazySingleton<SendEmailVerification>(
        () =>
        SendEmailVerification(
          getIt<AuthRepository>(),
        ),
  );

  getIt.registerLazySingleton<CheckNameAvailability>(
        () =>
        CheckNameAvailability(
          getIt<AuthRepository>(),
        ),
  );

  getIt.registerLazySingleton<SaveUserProfile>(
        () =>
        SaveUserProfile(
          getIt<AuthRepository>(),
        ),
  );
  getIt.registerLazySingleton<ForgotPassword>(
        () =>
        ForgotPassword(
          getIt<AuthRepository>(),
        ),
  );

  // Auth Cubit

  getIt.registerFactory(
        () => AuthCubit(
          login: getIt(),
          signup: getIt(),
          loginWithGoogle: getIt(),
          checkEmailVerified: getIt(),
          sendEmailVerification: getIt(),
          checkNameAvailability: getIt(),
          saveUserProfile: getIt(),
          forgotPassword: getIt(),
    ),
  );
}