import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  const DoctorEntity({
    this.id,
    required this.name,
    required this.specialty,
    required this.categoryId,
    required this.categoryName,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.availableTime,
    required this.imagePath,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  final String? id;
  final String name;
  final String specialty;
  final String categoryId;
  final String categoryName;
  final String address;
  final double rating;
  final int reviewsCount;
  final String availableTime;
  final String imagePath;
  final DateTime? createdAt;

  final double? latitude;
  final double? longitude;

  DoctorEntity copyWith({
    String? id,
    String? name,
    String? specialty,
    String? categoryId,
    String? categoryName,
    String? address,
    double? rating,
    int? reviewsCount,
    String? availableTime,
    String? imagePath,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) {
    return DoctorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      availableTime: availableTime ?? this.availableTime,
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
    specialty,
    categoryId,
    categoryName,
    address,
    rating,
    reviewsCount,
    availableTime,
    imagePath,
    createdAt,
    latitude,
    longitude,
  ];
}