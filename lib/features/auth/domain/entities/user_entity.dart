import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? nickname;
  final String? birthDate;
  final String? gender;
  final bool isNewUser;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.nickname,
    this.birthDate,
    this.gender,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    nickname,
    birthDate,
    gender,
    isNewUser,
  ];
}