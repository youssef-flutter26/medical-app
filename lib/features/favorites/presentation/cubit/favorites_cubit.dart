import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/doctor_repository.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import '../../domain/repositories/favorite_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoriteRepository favoriteRepository;
  final DoctorRepository doctorRepository;
  final HomeRepository homeRepository;
  final FirebaseAuth firebaseAuth;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Set<String>>? _doctorIdsSubscription;
  StreamSubscription<Set<String>>? _medicalCenterIdsSubscription;
  StreamSubscription<List<DoctorEntity>>? _doctorsSubscription;
  StreamSubscription<List<MedicalCenterEntity>>? _medicalCentersSubscription;

  FavoritesCubit({
    required this.favoriteRepository,
    required this.doctorRepository,
    required this.homeRepository,
    required this.firebaseAuth,
  }) : super(const FavoritesState());

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? 'guest';

  void init() {
    emit(state.copyWith(isLoading: true));

    // Listen to real-time doctors and medical centers from Firestore
    _doctorsSubscription?.cancel();
    _doctorsSubscription = doctorRepository.getDoctorsStream().listen(
      (doctors) {
        emit(state.copyWith(allDoctors: doctors));
      },
      onError: (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      },
    );

    _medicalCentersSubscription?.cancel();
    _medicalCentersSubscription =
        homeRepository.getMedicalCentersStream().listen(
      (centers) {
        emit(state.copyWith(allMedicalCenters: centers));
      },
      onError: (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      },
    );

    // Listen to Auth changes to reload favorites when user changes
    _authSubscription?.cancel();
    _authSubscription = firebaseAuth.authStateChanges().listen((user) {
      _loadFavoritesForUser(user?.uid ?? 'guest');
    });

    _loadFavoritesForUser(_currentUserId);
  }

  void _loadFavoritesForUser(String userId) async {
    // 1. Load initial cache instantly
    final initialDoctorIds =
        await favoriteRepository.getInitialFavoriteDoctorIds(userId);
    final initialCenterIds =
        await favoriteRepository.getInitialFavoriteMedicalCenterIds(userId);

    emit(state.copyWith(
      favoriteDoctorIds: initialDoctorIds,
      favoriteMedicalCenterIds: initialCenterIds,
      isLoading: false,
    ));

    // 2. Listen to real-time updates from Firestore
    _doctorIdsSubscription?.cancel();
    _doctorIdsSubscription =
        favoriteRepository.getFavoriteDoctorIdsStream(userId).listen((ids) {
      emit(state.copyWith(favoriteDoctorIds: ids));
    });

    _medicalCenterIdsSubscription?.cancel();
    _medicalCenterIdsSubscription = favoriteRepository
        .getFavoriteMedicalCenterIdsStream(userId)
        .listen((ids) {
      emit(state.copyWith(favoriteMedicalCenterIds: ids));
    });
  }

  void setTab(int index) {
    if (state.selectedTab == index) return;
    emit(state.copyWith(selectedTab: index));
  }

  bool isDoctorFavorite(String? doctorId) => state.isDoctorFavorite(doctorId);

  bool isMedicalCenterFavorite(String? centerId) =>
      state.isMedicalCenterFavorite(centerId);

  Future<void> toggleDoctorFavorite(String doctorId) async {
    if (doctorId.isEmpty) return;
    final currentIds = Set<String>.from(state.favoriteDoctorIds);
    final isCurrentlyFav = currentIds.contains(doctorId);

    if (isCurrentlyFav) {
      currentIds.remove(doctorId);
      emit(state.copyWith(favoriteDoctorIds: currentIds));
      await favoriteRepository.removeDoctorFavorite(_currentUserId, doctorId);
    } else {
      currentIds.add(doctorId);
      emit(state.copyWith(favoriteDoctorIds: currentIds));
      await favoriteRepository.addDoctorFavorite(_currentUserId, doctorId);
    }
  }

  Future<void> removeDoctorFavorite(String doctorId) async {
    if (doctorId.isEmpty) return;
    final currentIds = Set<String>.from(state.favoriteDoctorIds);
    if (!currentIds.contains(doctorId)) return;

    currentIds.remove(doctorId);
    emit(state.copyWith(favoriteDoctorIds: currentIds));
    await favoriteRepository.removeDoctorFavorite(_currentUserId, doctorId);
  }

  Future<void> toggleMedicalCenterFavorite(String centerId) async {
    if (centerId.isEmpty) return;
    final currentIds = Set<String>.from(state.favoriteMedicalCenterIds);
    final isCurrentlyFav = currentIds.contains(centerId);

    if (isCurrentlyFav) {
      currentIds.remove(centerId);
      emit(state.copyWith(favoriteMedicalCenterIds: currentIds));
      await favoriteRepository.removeMedicalCenterFavorite(
        _currentUserId,
        centerId,
      );
    } else {
      currentIds.add(centerId);
      emit(state.copyWith(favoriteMedicalCenterIds: currentIds));
      await favoriteRepository.addMedicalCenterFavorite(
        _currentUserId,
        centerId,
      );
    }
  }

  Future<void> removeMedicalCenterFavorite(String centerId) async {
    if (centerId.isEmpty) return;
    final currentIds = Set<String>.from(state.favoriteMedicalCenterIds);
    if (!currentIds.contains(centerId)) return;

    currentIds.remove(centerId);
    emit(state.copyWith(favoriteMedicalCenterIds: currentIds));
    await favoriteRepository.removeMedicalCenterFavorite(
      _currentUserId,
      centerId,
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _doctorIdsSubscription?.cancel();
    _medicalCenterIdsSubscription?.cancel();
    _doctorsSubscription?.cancel();
    _medicalCentersSubscription?.cancel();
    return super.close();
  }
}
