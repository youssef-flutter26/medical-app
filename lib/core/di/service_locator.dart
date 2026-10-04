import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:medical_app/core/routing/app_router.dart';

import 'package:medical_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medical_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source_impl.dart';

import 'package:medical_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';

import 'package:medical_app/features/auth/domain/usecases/check_email_verified.dart';
import 'package:medical_app/features/auth/domain/usecases/check_name_availability.dart';
import 'package:medical_app/features/auth/domain/usecases/forgot_password.dart';
import 'package:medical_app/features/auth/domain/usecases/login.dart';
import 'package:medical_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:medical_app/features/auth/domain/usecases/save_user_profile.dart';
import 'package:medical_app/features/auth/domain/usecases/send_email_verification.dart';
import 'package:medical_app/features/auth/domain/usecases/signup.dart';

import 'package:medical_app/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:medical_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';

import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';


import 'package:medical_app/features/location/data/datasources/location_remote_data_source.dart';
import 'package:medical_app/features/location/data/datasources/location_remote_data_source_impl.dart';

import 'package:medical_app/features/location/data/repositories/location_repository_impl.dart';
import 'package:medical_app/features/location/domain/repositories/location_repository.dart';

import 'package:medical_app/features/location/domain/usecases/get_current_location.dart';
import 'package:medical_app/features/location/domain/usecases/search_nearby_places.dart';

import 'package:medical_app/features/location/presentation/cubit/location_cubit.dart';


import '../../features/home/data/datasources/doctor_remote_data_source.dart';
import '../../features/home/data/datasources/doctor_remote_data_source_impl.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source_impl.dart';
import '../../features/home/data/repositories/doctor_repository_impl.dart';
import '../../features/home/domain/repositories/doctor_repository.dart';
import '../../features/home/domain/usecases/add_doctor.dart';
import '../../features/home/domain/usecases/get_doctors_by_category_stream.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // ==========================================
  // CORE
  // ==========================================

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

  // ==========================================
  // AUTH
  // ==========================================

  // ------------------------------------------
  // Data Sources
  // ------------------------------------------

  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () =>
        AuthRemoteDataSourceImpl(
          getIt<FirebaseAuth>(),
        ),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
        () =>
        UserRemoteDataSourceImpl(
          getIt<FirebaseFirestore>(),
        ),
  );

  // ------------------------------------------
  // Repository
  // ------------------------------------------

  getIt.registerLazySingleton<AuthRepository>(
        () =>
        AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<UserRemoteDataSource>(),
    ),
  );

  // ------------------------------------------
  // Use Cases
  // ------------------------------------------

  getIt.registerLazySingleton<Login>(
        () =>
        Login(
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
        () =>
        Signup(
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

  // ------------------------------------------
  // Auth Cubit
  // ------------------------------------------

  getIt.registerFactory<AuthCubit>(
        () =>
        AuthCubit(
          login: getIt<Login>(),
          signup: getIt<Signup>(),
          loginWithGoogle: getIt<LoginWithGoogle>(),
          checkEmailVerified: getIt<CheckEmailVerified>(),
          sendEmailVerification: getIt<SendEmailVerification>(),
          checkNameAvailability: getIt<CheckNameAvailability>(),
          saveUserProfile: getIt<SaveUserProfile>(),
          forgotPassword: getIt<ForgotPassword>(),
        ),
  );

  // ==========================================
  // HOME
  // ==========================================

  // ------------------------------------------
  // Data Source
  // ------------------------------------------

  getIt.registerLazySingleton<HomeRemoteDataSource>(
        () =>
        HomeRemoteDataSourceImpl(
          getIt<FirebaseFirestore>(),
        ),
  );

  // ------------------------------------------
  // Repository
  // ------------------------------------------

  getIt.registerLazySingleton<HomeRepository>(
        () =>
        HomeRepositoryImpl(
          getIt<HomeRemoteDataSource>(),
        ),
  );

  // ------------------------------------------
  // Use Cases
  // ------------------------------------------

  getIt.registerLazySingleton<AddMedicalCenter>(
        () =>
        AddMedicalCenter(
          getIt<HomeRepository>(),
        ),
  );

  // ==========================================
  // DOCTOR
  // ==========================================

  // ------------------------------------------
  // Data Source
  // ------------------------------------------

  getIt.registerLazySingleton<DoctorRemoteDataSource>(
        () =>
        DoctorRemoteDataSourceImpl(
          getIt<FirebaseFirestore>(),
        ),
  );

  // ------------------------------------------
  // Repository
  // ------------------------------------------

  getIt.registerLazySingleton<DoctorRepository>(
        () =>
        DoctorRepositoryImpl(
          getIt<DoctorRemoteDataSource>(),
        ),
  );

  // ------------------------------------------
  // Use Cases
  // ------------------------------------------

  getIt.registerLazySingleton<AddDoctor>(
        () =>
        AddDoctor(
          getIt<DoctorRepository>(),
        ),
  );

  getIt.registerLazySingleton<GetDoctorsByCategoryStream>(
        () =>
        GetDoctorsByCategoryStream(
          getIt<DoctorRepository>(),
    ),
  );

  // ==========================================
  // LOCATION
  // ==========================================

  // ------------------------------------------
  // Data Source
  // ------------------------------------------

  getIt.registerLazySingleton<LocationRemoteDataSource>(
        () =>
        LocationRemoteDataSourceImpl(
          firestore: getIt<FirebaseFirestore>(),
        ),
  );

  // ------------------------------------------
  // Repository
  // ------------------------------------------

  getIt.registerLazySingleton<LocationRepository>(
        () =>
        LocationRepositoryImpl(
          getIt<LocationRemoteDataSource>(),
        ),
  );

  // ------------------------------------------
  // Use Cases
  // ------------------------------------------

  getIt.registerLazySingleton<GetCurrentLocation>(
        () =>
        GetCurrentLocation(
          getIt<LocationRepository>(),
        ),
  );

  getIt.registerLazySingleton<SearchNearbyPlaces>(
        () =>
        SearchNearbyPlaces(
          getIt<LocationRepository>(),
        ),
  );

  // ------------------------------------------
  // Location Cubit
  // ------------------------------------------

  getIt.registerFactory<LocationCubit>(
        () =>
        LocationCubit(
          getCurrentLocation: getIt<GetCurrentLocation>(),
          searchNearbyPlaces: getIt<SearchNearbyPlaces>(),
        ),
  );
}