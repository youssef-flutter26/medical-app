import 'package:equatable/equatable.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

class FavoritesState extends Equatable {
  final Set<String> favoriteDoctorIds;
  final Set<String> favoriteMedicalCenterIds;
  final List<DoctorEntity> allDoctors;
  final List<MedicalCenterEntity> allMedicalCenters;
  final int selectedTab; // 0 for Doctors, 1 for Hospitals
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favoriteDoctorIds = const {},
    this.favoriteMedicalCenterIds = const {},
    this.allDoctors = const [],
    this.allMedicalCenters = const [],
    this.selectedTab = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  List<DoctorEntity> get favoriteDoctors {
    return allDoctors
        .where((d) => d.id != null && favoriteDoctorIds.contains(d.id))
        .toList();
  }

  List<MedicalCenterEntity> get favoriteMedicalCenters {
    return allMedicalCenters
        .where((c) => c.id != null && favoriteMedicalCenterIds.contains(c.id))
        .toList();
  }

  bool isDoctorFavorite(String? doctorId) {
    if (doctorId == null) return false;
    return favoriteDoctorIds.contains(doctorId);
  }

  bool isMedicalCenterFavorite(String? centerId) {
    if (centerId == null) return false;
    return favoriteMedicalCenterIds.contains(centerId);
  }

  FavoritesState copyWith({
    Set<String>? favoriteDoctorIds,
    Set<String>? favoriteMedicalCenterIds,
    List<DoctorEntity>? allDoctors,
    List<MedicalCenterEntity>? allMedicalCenters,
    int? selectedTab,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoriteDoctorIds: favoriteDoctorIds ?? this.favoriteDoctorIds,
      favoriteMedicalCenterIds:
          favoriteMedicalCenterIds ?? this.favoriteMedicalCenterIds,
      allDoctors: allDoctors ?? this.allDoctors,
      allMedicalCenters: allMedicalCenters ?? this.allMedicalCenters,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        favoriteDoctorIds,
        favoriteMedicalCenterIds,
        allDoctors,
        allMedicalCenters,
        selectedTab,
        isLoading,
        errorMessage,
      ];
}
