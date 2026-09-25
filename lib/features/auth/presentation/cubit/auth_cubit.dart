import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart' hide AuthFailure;
import '../../../../core/error/result.dart';
import '../../domain/usecases/check_email_verified.dart';
import '../../domain/usecases/check_name_availability.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/save_user_profile.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/signup.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Login login;
  final Signup signup;
  final LoginWithGoogle loginWithGoogle;
  final CheckEmailVerified checkEmailVerified;
  final SendEmailVerification sendEmailVerification;
  final CheckNameAvailability checkNameAvailability;
  final SaveUserProfile saveUserProfile;
  final ForgotPassword forgotPassword;

  AuthCubit({
    required this.login,
    required this.signup,
    required this.loginWithGoogle,
    required this.checkEmailVerified,
    required this.sendEmailVerification,
    required this.checkNameAvailability,
    required this.saveUserProfile,
    required this.forgotPassword,
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
      case SuccessAPI(data: final googleResult):
        emit(
          GoogleLoginSuccess(
            user: googleResult.user,
            isNewUser: googleResult.isNewUser,
          ),
        );

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

    // Check name before creating Firebase account.
    final nameResult = await checkNameAvailability(
      name: name,
    );

    switch (nameResult) {
      case SuccessAPI(data: final isTaken):
        if (isTaken) {
          emit(
            const AuthFailure(
              'This name is already taken.',
            ),
          );
          return;
        }

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
        return;
    }

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

  Future<bool> isEmailVerified() async {
    final result = await checkEmailVerified();

    switch (result) {
      case SuccessAPI(data: final verified):
        return verified;

      case ErrorAPI():
        return false;
    }
  }

  Future<void> resendEmailVerification() async {
    emit(const AuthLoading());

    final result = await sendEmailVerification();

    switch (result) {
      case SuccessAPI():
        emit(
          const VerificationEmailSent(
            'Verification email sent successfully.',
          ),
        );

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
    }
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    emit(const AuthLoading());

    final result = await forgotPassword(
      email: email,
    );

    switch (result) {
      case SuccessAPI():
        emit(const PasswordResetEmailSent());

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String nickname,
    required String email,
    required String birthDate,
    required String gender,
  }) async {
    emit(const AuthLoading());

    final result = await saveUserProfile(
      name: name,
      nickname: nickname,
      email: email,
      birthDate: birthDate,
      gender: gender,
    );

    switch (result) {
      case SuccessAPI():
        emit(const ProfileSaved());
        return true;

      case ErrorAPI(failure: final failure):
        emit(AuthFailure(failure.userMessage));
        return false;
    }
  }

  Future<bool> isNameTaken({
    required String name,
  }) async {
    final result = await checkNameAvailability(
      name: name,
    );

    switch (result) {
      case SuccessAPI(data: final isTaken):
        return isTaken;

      case ErrorAPI():
        return false;
    }
  }
}