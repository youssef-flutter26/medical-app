import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';

class SendEmailVerification {
  final AuthRepository repository;

  SendEmailVerification(this.repository);

  Future<Result<void>> call() {
    return repository.sendEmailVerification();
  }
}
