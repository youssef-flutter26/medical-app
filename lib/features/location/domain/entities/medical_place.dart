import 'package:equatable/equatable.dart';

enum MedicalPlaceType {
  hospital,
  clinic,
  doctor,
}

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

  /// Distance in kilometers.
  /// Calculated at runtime from user's location.
  final double distance;

  final MedicalPlaceType type;

  final String? imageUrl;
  final String? specialty;

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }

    return '${distance.toStringAsFixed(1)} km';
  }

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