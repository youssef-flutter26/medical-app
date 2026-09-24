import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
  });

  factory UserModel.fromFirebase({
    required String id,
    required String email,
    String? name,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
    );
  }
}