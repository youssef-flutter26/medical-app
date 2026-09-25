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

class GoogleLoginSuccess extends AuthState {
  final UserEntity user;
  final bool isNewUser;

  const GoogleLoginSuccess({
    required this.user,
    required this.isNewUser,
  });
}

class VerificationEmailSent extends AuthState {
  final String message;

  const VerificationEmailSent(this.message);
}

class ProfileSaved extends AuthState {
  const ProfileSaved();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}