import 'package:equatable/equatable.dart';

class MedicalCenterEntity extends Equatable {
  const MedicalCenterEntity({
    this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.type,
    required this.imagePath,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  final String? id;
  final String name;
  final String address;
  final double rating;
  final int reviewsCount;
  final double distance;
  final String type;
  final String imagePath;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }

    return '${distance.toStringAsFixed(1)} km';
  }

  MedicalCenterEntity copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    int? reviewsCount,
    double? distance,
    String? type,
    String? imagePath,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) {
    return MedicalCenterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      distance: distance ?? this.distance,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    rating,
    reviewsCount,
    distance,
    type,
    imagePath,
    createdAt,
    latitude,
    longitude,
  ];
}