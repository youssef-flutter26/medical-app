import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/core/routing/app_router.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<AppRouter>(() => AppRouter());
}
