import '../../../../core/error/result.dart';
import '../../data/models/google_login_result.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository repository;

  LoginWithGoogle(this.repository);

  Future<Result<GoogleLoginResult>> call() {
    return repository.loginWithGoogle();
  }
}
