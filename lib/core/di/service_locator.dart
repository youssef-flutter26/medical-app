import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());
}
