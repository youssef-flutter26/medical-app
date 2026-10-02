import 'package:medical_app/features/location/domain/entities/medical_place.dart';
import 'package:medical_app/features/location/domain/repositories/location_repository.dart';

class SearchNearbyPlaces {
  SearchNearbyPlaces(this.repository);

  final LocationRepository repository;

  Future<List<MedicalPlace>> call({
    required double latitude,
    required double longitude,
    String? query,
  }) {
    return repository.searchNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      query: query,
    );
  }
}
