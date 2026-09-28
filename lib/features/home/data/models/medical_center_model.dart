import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

class MedicalCenterModel extends MedicalCenterEntity {
  const MedicalCenterModel({
    super.id,
    required super.name,
    required super.address,
    required super.rating,
    required super.reviewsCount,
    required super.distance,
    required super.duration,
    required super.type,
    required super.imagePath,
    super.createdAt,
  });

  factory MedicalCenterModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    return MedicalCenterModel(
      id: docId,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
      distance: json['distance'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      type: json['type'] as String? ?? 'Hospital',
      imagePath: (json['imagePath'] as String?) ??
          (json['imageUrl'] as String?) ??
          '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'distance': distance,
      'duration': duration,
      'type': type,
      'imagePath': imagePath,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory MedicalCenterModel.fromEntity(MedicalCenterEntity entity) {
    return MedicalCenterModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      distance: entity.distance,
      duration: entity.duration,
      type: entity.type,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
    );
  }
}
