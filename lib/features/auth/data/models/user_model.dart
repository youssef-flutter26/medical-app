import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.nickname,
    super.birthDate,
    super.gender,
    super.isNewUser,
  });

  factory UserModel.fromFirebase({
    required String id,
    required String email,
    String? name,
    String? nickname,
    String? birthDate,
    String? gender,
    bool isNewUser = false,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      nickname: nickname,
      birthDate: birthDate,
      gender: gender,
      isNewUser: isNewUser,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] as String,
      email: data['email'] as String,
      name: data['name'] as String?,
      nickname: data['nickname'] as String?,
      birthDate: data['birthDate'] as String?,
      gender: data['gender'] as String?,
      isNewUser: false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'email': email,
      'name': name,
      'nickname': nickname,
      'birthDate': birthDate,
      'gender': gender,
    };
  }
}