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

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] as String,
      email: data['email'] as String,
      name: data['name'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'email': email,
      'name': name,
    };
  }
}