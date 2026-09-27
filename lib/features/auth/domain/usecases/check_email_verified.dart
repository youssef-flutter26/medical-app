import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/result.dart';

class CheckEmailVerified {
  final AuthRepository repository;

  CheckEmailVerified(this.repository);

  Future<Result<bool>> call() {
    return repository.checkEmailVerified();
  }
}
