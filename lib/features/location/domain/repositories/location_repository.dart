import 'package:medical_app/features/location/domain/entities/medical_place.dart';

import '../entities/medical_location_result.dart';

abstract class LocationRepository {
  Future<MedicalLocationResult> getCurrentLocation();

  Future<List<MedicalPlace>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    String? query,
  });
}
