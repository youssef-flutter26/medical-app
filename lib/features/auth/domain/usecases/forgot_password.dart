import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  Future<Result<void>> call({required String email}) {
    return repository.sendPasswordResetEmail(email: email);
  }
}
