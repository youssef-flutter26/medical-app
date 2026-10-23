import 'package:equatable/equatable.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity? user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileLoggingOut extends ProfileState {
  const ProfileLoggingOut();
}

class ProfileLogoutSuccess extends ProfileState {
  const ProfileLogoutSuccess();
}

class ProfileLogoutFailure extends ProfileState {
  final String message;

  const ProfileLogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
