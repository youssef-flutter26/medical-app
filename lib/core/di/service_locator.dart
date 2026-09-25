import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/datasources/user_remote_data_source.dart';
import '../../features/auth/data/datasources/user_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
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

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
          getIt<UserRemoteDataSource>(),
    ),
  );

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

  getIt.registerFactory(
        () => AuthCubit(
          login: getIt(),
          signup: getIt(),
          loginWithGoogle: getIt(),
    ),
  );
}