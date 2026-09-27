import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';

class SaveUserProfile {
  final AuthRepository repository;

  SaveUserProfile(this.repository);

  Future<Result<void>> call({
    required String name,
    required String nickname,
    required String email,
    required String birthDate,
    required String gender,
  }) {
    return repository.saveUserProfile(
      name: name,
      nickname: nickname,
      email: email,
      birthDate: birthDate,
      gender: gender,
    );
  }
}
