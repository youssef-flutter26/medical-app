import 'package:medical_app/features/location/domain/repositories/location_repository.dart';

import '../entities/medical_location_result.dart';

class GetCurrentLocation {
  GetCurrentLocation(this.repository);

  final LocationRepository repository;

  Future<MedicalLocationResult> call() {
    return repository.getCurrentLocation();
  }
}
