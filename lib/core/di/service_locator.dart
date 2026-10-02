import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/core/routing/app_router.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/doctor/data/datasources/doctor_remote_data_source.dart';
import 'package:medical_app/features/doctor/data/datasources/doctor_remote_data_source_impl.dart';
import 'package:medical_app/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:medical_app/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:medical_app/features/doctor/domain/usecases/add_doctor.dart';
import 'package:medical_app/features/home/domain/usecases/add_banner.dart';
import 'package:medical_app/features/home/domain/usecases/add_category.dart';
import 'package:medical_app/features/home/domain/usecases/update_category.dart';
import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';
import 'package:medical_app/features/home/domain/usecases/get_banners_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_medical_centers_stream.dart';
import 'package:medical_app/features/home/domain/usecases/update_banner.dart';
import 'package:medical_app/features/home/domain/usecases/update_medical_center.dart';
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

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<AppRouter>(() => AppRouter());

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<UserRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  );

  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(getIt<DoctorRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<AddDoctor>(
    () => AddDoctor(getIt<DoctorRepository>()),
  );
  getIt.registerLazySingleton<AddBanner>(
    () => AddBanner(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<UpdateBanner>(
    () => UpdateBanner(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<GetBannersStream>(
    () => GetBannersStream(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<AddMedicalCenter>(
    () => AddMedicalCenter(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<UpdateMedicalCenter>(
    () => UpdateMedicalCenter(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<GetMedicalCentersStream>(
    () => GetMedicalCentersStream(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<AddCategory>(
    () => AddCategory(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<UpdateCategory>(
    () => UpdateCategory(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<GetCategoriesStream>(
    () => GetCategoriesStream(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<Login>(() => Login(getIt<AuthRepository>()));

  getIt.registerLazySingleton<LoginWithGoogle>(
    () => LoginWithGoogle(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<Signup>(() => Signup(getIt<AuthRepository>()));

  getIt.registerLazySingleton<CheckEmailVerified>(
    () => CheckEmailVerified(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SendEmailVerification>(
    () => SendEmailVerification(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<CheckNameAvailability>(
    () => CheckNameAvailability(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SaveUserProfile>(
    () => SaveUserProfile(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<ForgotPassword>(
    () => ForgotPassword(getIt<AuthRepository>()),
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
