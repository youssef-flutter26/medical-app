import 'package:equatable/equatable.dart';
import 'package:medical_app/features/location/domain/entities/medical_place.dart';

enum LocationStatus { initial, loading, success, failure }

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.latitude,
    this.longitude,
    this.places = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.isLocationServiceDisabled = false,
    this.selectedPlace,
  });

  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final List<MedicalPlace> places;
  final String? errorMessage;
  final String searchQuery;
  final bool isLocationServiceDisabled;
  final MedicalPlace? selectedPlace;

  LocationState copyWith({
    LocationStatus? status,
    double? latitude,
    double? longitude,
    List<MedicalPlace>? places,
    String? errorMessage,
    String? searchQuery,
    bool? isLocationServiceDisabled,
    MedicalPlace? selectedPlace,
    bool clearSelectedPlace = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      places: places ?? this.places,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLocationServiceDisabled:
          isLocationServiceDisabled ?? this.isLocationServiceDisabled,
      selectedPlace: clearSelectedPlace
          ? null
          : selectedPlace ?? this.selectedPlace,
    );
  }

  @override
  List<Object?> get props => [
    status,
    latitude,
    longitude,
    places,
    errorMessage,
    searchQuery,
    isLocationServiceDisabled,
    selectedPlace,
  ];
}
