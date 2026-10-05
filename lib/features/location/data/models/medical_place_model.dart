import 'package:medical_app/features/location/domain/entities/medical_place.dart';

class MedicalPlaceModel extends MedicalPlace {
  const MedicalPlaceModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.rating,
    required super.reviewsCount,
    required super.distance,
    required super.type,
    super.imageUrl,
    super.specialty,
  });

  factory MedicalPlaceModel.fromEntity(MedicalPlace place,) {
    return MedicalPlaceModel(
      id: place.id,
      name: place.name,
      address: place.address,
      latitude: place.latitude,
      longitude: place.longitude,
      rating: place.rating,
      reviewsCount: place.reviewsCount,
      distance: place.distance,
      type: place.type,
      imageUrl: place.imageUrl,
      specialty: place.specialty,
    );
  }
}