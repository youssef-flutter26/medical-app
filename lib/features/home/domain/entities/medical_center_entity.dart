import 'package:equatable/equatable.dart';

class MedicalCenterEntity extends Equatable {
  final String? id;
  final String name;
  final String address;
  final double rating;
  final int reviewsCount;
  final double distance;
  final int duration;
  final String type;
  final String imagePath;
  final DateTime? createdAt;

  const MedicalCenterEntity({
    this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.duration,
    required this.type,
    required this.imagePath,
    this.createdAt,
  });

  String get formattedDistance =>
      distance == distance.roundToDouble() ? '${distance.toInt()} km' : '$distance km';

  String get formattedDuration => '$duration min';

  MedicalCenterEntity copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    int? reviewsCount,
    double? distance,
    int? duration,
    String? type,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return MedicalCenterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
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
        duration,
        type,
        imagePath,
        createdAt,
      ];
}
