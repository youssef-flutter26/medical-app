import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart' hide AuthFailure;
import '../../../../core/error/result.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/signup.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Login login;
  final Signup signup;
  final LoginWithGoogle loginWithGoogle;

  AuthCubit({
    required this.login,
    required this.signup,
    required this.loginWithGoogle,
  }) : super(const AuthInitial());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await login(
      email: email,
      password: password,
    );

    switch (result) {
      case SuccessAPI(data: final user):
        emit(LoginSuccess(user));

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
    }
  }

  Future<void> loginWithGoogleUser() async {
    emit(const AuthLoading());

    final result = await loginWithGoogle();

    switch (result) {
      case SuccessAPI(data: final user):
        emit(LoginSuccess(user));

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
    }
  }

  Future<void> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());

    final result = await signup(
      email: email,
      password: password,
      name: name,
    );

    switch (result) {
      case SuccessAPI(data: final user):
        emit(SignupSuccess(user));

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
    }
  }
}