import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
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
      (userModel) async {
        String? photo = userModel?.photoUrl;
        if (photo == null || photo.isEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            photo = prefs.getString('profile_photo_${currentUser.uid}') ??
                currentUser.photoURL;
          } catch (_) {}
        }

        if (userModel != null) {
          emit(ProfileLoaded(
            UserModel(
              id: userModel.id,
              email: userModel.email,
              name: userModel.name,
              nickname: userModel.nickname,
              birthDate: userModel.birthDate,
              gender: userModel.gender,
              photoUrl: photo,
              role: userModel.role,
            ),
          ));
        } else {
          emit(ProfileLoaded(
            UserEntity(
              id: currentUser.uid,
              email: currentUser.email ?? '',
              name: currentUser.displayName,
              photoUrl: photo,
            ),
          ));
        }
      },
      onError: (_) async {
        String? photo;
        try {
          final prefs = await SharedPreferences.getInstance();
          photo = prefs.getString('profile_photo_${currentUser.uid}') ??
              currentUser.photoURL;
        } catch (_) {}

        emit(
          ProfileLoaded(
            UserEntity(
              id: currentUser.uid,
              email: currentUser.email ?? '',
              name: currentUser.displayName,
              photoUrl: photo,
            ),
          ),
        );
      },
    );
  }

  Future<void> updatePhoto(String photoPath) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) return;

    // 1. Immediately cache in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_${currentUser.uid}', photoPath);
    } catch (e) {
      debugPrint('Error saving photo to SharedPreferences: $e');
    }

    // 2. Immediately reflect in current state
    if (state is ProfileLoaded) {
      final current = (state as ProfileLoaded).user;
      if (current != null) {
        emit(ProfileLoaded(
          UserModel(
            id: current.id,
            email: current.email,
            name: current.name,
            nickname: current.nickname,
            birthDate: current.birthDate,
            gender: current.gender,
            photoUrl: photoPath,
            role: current.role,
          ),
        ));
      }
    }

    // 3. Persist to Firestore
    try {
      final existingUser = await userRemoteDataSource.getUser(currentUser.uid);
      final userModel = UserModel(
        id: currentUser.uid,
        email: existingUser?.email ?? currentUser.email ?? '',
        name: existingUser?.name ?? currentUser.displayName,
        nickname: existingUser?.nickname,
        birthDate: existingUser?.birthDate,
        gender: existingUser?.gender,
        photoUrl: photoPath,
        role: existingUser?.role ?? 'user',
      );
      await userRemoteDataSource.saveUser(userModel);

      if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
        try {
          await currentUser.updatePhotoURL(photoPath);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error saving photo to Firestore: $e');
    }
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
