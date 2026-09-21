import '../../domain/entities/user_entity.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class LoginSuccess extends AuthState {
  final UserEntity user;

  const LoginSuccess(this.user);
}

class SignupSuccess extends AuthState {
  final UserEntity user;

  const SignupSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}