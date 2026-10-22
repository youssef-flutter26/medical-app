import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository authRepository;
  final UserRemoteDataSource userRemoteDataSource;
  final FirebaseAuth firebaseAuth;
  StreamSubscription<UserEntity?>? _userSubscription;

  ProfileCubit({
    required this.authRepository,
    required this.userRemoteDataSource,
    required this.firebaseAuth,
  }) : super(const ProfileInitial());

  void init() {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const ProfileLoaded(null));
      return;
    }

    emit(const ProfileLoading());
    _userSubscription?.cancel();
    _userSubscription = userRemoteDataSource
        .getUserStream(currentUser.uid)
        .listen(
      (userModel) {
        emit(ProfileLoaded(userModel));
      },
      onError: (_) {
        emit(
          ProfileLoaded(
            UserEntity(
              id: currentUser.uid,
              email: currentUser.email ?? '',
              name: currentUser.displayName,
            ),
          ),
        );
      },
    );
  }

  Future<bool> logout() async {
    emit(const ProfileLoggingOut());
    final result = await authRepository.logout();
    switch (result) {
      case SuccessAPI():
        emit(const ProfileLogoutSuccess());
        return true;
      case ErrorAPI(failure: final failure):
        emit(ProfileLogoutFailure(failure.message));
        return false;
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
