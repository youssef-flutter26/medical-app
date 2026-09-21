import '../../../../core/error/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<void>> logout();
}