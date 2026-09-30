import 'package:geolocator/geolocator.dart';
import 'package:medical_app/features/location/data/datasources/location_local_data_source.dart';
import 'package:medical_app/features/location/domain/entities/medical_location_result.dart';
import 'package:medical_app/features/location/domain/entities/medical_place.dart';
import 'package:medical_app/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this.localDataSource);

  final LocationLocalDataSource localDataSource;

  @override
  Future<MedicalLocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const PermissionDeniedException('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        'Location permission is permanently denied.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return MedicalLocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<List<MedicalPlace>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    String? query,
  }) async {
    final places = await localDataSource.getMedicalPlaces();

    final normalizedQuery = query?.trim().toLowerCase();

    final filteredPlaces = places.where((place) {
      if (normalizedQuery == null || normalizedQuery.isEmpty) {
        return true;
      }

      final name = place.name.toLowerCase();
      final address = place.address.toLowerCase();
      final specialty = place.specialty?.toLowerCase() ?? '';
      final type = place.type.name.toLowerCase();

      return name.contains(normalizedQuery) ||
          address.contains(normalizedQuery) ||
          specialty.contains(normalizedQuery) ||
          type.contains(normalizedQuery);
    }).toList();

    final result = filteredPlaces.map((place) {
      final distanceInMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        place.latitude,
        place.longitude,
      );

      return _copyWithDistance(place, distanceInMeters / 1000);
    }).toList();

    result.sort((a, b) => a.distance.compareTo(b.distance));

    return result;
  }

  MedicalPlace _copyWithDistance(MedicalPlace place, double distance) {
    return MedicalPlace(
      id: place.id,
      name: place.name,
      address: place.address,
      latitude: place.latitude,
      longitude: place.longitude,
      rating: place.rating,
      reviewsCount: place.reviewsCount,
      distance: distance,
      type: place.type,
      imageUrl: place.imageUrl,
      specialty: place.specialty,
    );
  }
}
