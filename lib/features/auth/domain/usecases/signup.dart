import '../../../../core/error/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class Signup {
  final AuthRepository repository;

  Signup(this.repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.signup(
      email: email,
      password: password,
      name: name,
    );
  }
}