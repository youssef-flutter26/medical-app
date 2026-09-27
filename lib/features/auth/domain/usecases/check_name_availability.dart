import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';

class CheckNameAvailability {
  final AuthRepository repository;

  CheckNameAvailability(this.repository);

  Future<Result<bool>> call({required String name}) {
    return repository.isNameTaken(name: name);
  }
}
