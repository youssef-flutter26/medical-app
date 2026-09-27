import '../../domain/entities/user_entity.dart';

class GoogleLoginResult {
  final UserEntity user;
  final bool isNewUser;

  const GoogleLoginResult({required this.user, required this.isNewUser});
}
