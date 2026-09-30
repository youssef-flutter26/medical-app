import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medical_app/features/location/domain/entities/medical_place.dart';
import 'package:medical_app/features/location/domain/usecases/get_current_location.dart';
import 'package:medical_app/features/location/domain/usecases/search_nearby_places.dart';
import 'package:medical_app/features/location/presentation/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit({
    required this.getCurrentLocation,
    required this.searchNearbyPlaces,
  }) : super(const LocationState());

  final GetCurrentLocation getCurrentLocation;
  final SearchNearbyPlaces searchNearbyPlaces;

  Future<void> initialize() async {
    try {
      emit(
        state.copyWith(
          status: LocationStatus.loading,
          isLocationServiceDisabled: false,
        ),
      );

      final location = await getCurrentLocation();

      emit(
        state.copyWith(
          latitude: location.latitude,
          longitude: location.longitude,
          status: LocationStatus.success,
          isLocationServiceDisabled: false,
          clearSelectedPlace: true,
        ),
      );

      await search();
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          isLocationServiceDisabled: _isLocationServiceDisabled(e),
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> search([String? query]) async {
    if (state.latitude == null || state.longitude == null) {
      return;
    }

    try {
      final searchQuery = query ?? state.searchQuery;

      final places = await searchNearbyPlaces(
        latitude: state.latitude!,
        longitude: state.longitude!,
        query: searchQuery,
      );

      emit(
        state.copyWith(
          status: LocationStatus.success,
          places: places,
          searchQuery: searchQuery,
          clearSelectedPlace: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  void selectPlace(MedicalPlace place) {
    emit(state.copyWith(selectedPlace: place, status: LocationStatus.success));
  }

  void goToMyLocation() {
    if (state.latitude == null || state.longitude == null) {
      return;
    }

    emit(
      state.copyWith(status: LocationStatus.success, clearSelectedPlace: true),
    );
  }

  String _getErrorMessage(Object error) {
    return error.toString();
  }

  bool _isLocationServiceDisabled(Object error) {
    return error is LocationServiceDisabledException;
  }
}
