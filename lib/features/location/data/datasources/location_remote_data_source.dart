import 'package:medical_app/features/location/data/models/medical_place_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<MedicalPlaceModel>> getMedicalPlaces();
}
