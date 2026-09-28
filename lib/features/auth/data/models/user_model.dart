import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.nickname,
    super.birthDate,
    super.gender,
    super.role = 'user',
    super.isNewUser,
  });

  factory UserModel.fromFirebase({
    required String id,
    required String email,
    String? name,
    String? nickname,
    String? birthDate,
    String? gender,
    String role = 'user',
    bool isNewUser = false,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      nickname: nickname,
      birthDate: birthDate,
      gender: gender,
      role: role,
      isNewUser: isNewUser,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: (data['uid'] ?? data['id'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      name: data['name'] as String?,
      nickname: data['nickname'] as String?,
      birthDate: data['birthDate'] as String?,
      gender: data['gender'] as String?,
      role: (data['role'] as String?)?.trim().isNotEmpty == true
          ? (data['role'] as String).trim()
          : 'user',
      isNewUser: false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'email': email,
      if (name != null) 'name': name,
      if (name != null) 'nameLowercase': name!.trim().toLowerCase(),
      if (nickname != null) 'nickname': nickname,
      if (birthDate != null) 'birthDate': birthDate,
      if (gender != null) 'gender': gender,
      'role': role,
    };
  }
}
