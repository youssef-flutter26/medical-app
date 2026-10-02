import 'package:equatable/equatable.dart';

enum MedicalPlaceType { hospital, doctor }

class MedicalPlace extends Equatable {
  const MedicalPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.type,
    this.imageUrl,
    this.specialty,
  });

  final String id;
  final String name;
  final String address;

  final double latitude;
  final double longitude;

  final double rating;
  final int reviewsCount;

  final double distance;

  final MedicalPlaceType type;

  final String? imageUrl;
  final String? specialty;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    rating,
    reviewsCount,
    distance,
    type,
    imageUrl,
    specialty,
  ];
}
