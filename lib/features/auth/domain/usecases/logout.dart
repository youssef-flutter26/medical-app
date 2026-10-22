import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Result<void>> call() {
    return repository.logout();
  }
}
