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
    final rawDistance = json['distance'];
    final double parsedDistance;
    if (rawDistance is num) {
      parsedDistance = rawDistance.toDouble();
    } else if (rawDistance is String && rawDistance.isNotEmpty) {
      final match = RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(rawDistance);
      parsedDistance =
          match != null ? (double.tryParse(match.group(0)!) ?? 0.0) : 0.0;
    } else {
      parsedDistance = 0.0;
    }

    final rawDuration = json['duration'];
    final int parsedDuration;
    if (rawDuration is num) {
      parsedDuration = rawDuration.toInt();
    } else if (rawDuration is String && rawDuration.isNotEmpty) {
      final match = RegExp(r'[0-9]+').firstMatch(rawDuration);
      parsedDuration =
          match != null ? (int.tryParse(match.group(0)!) ?? 0) : 0;
    } else {
      parsedDuration = 0;
    }

    return MedicalCenterModel(
      id: docId,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
      distance: parsedDistance,
      duration: parsedDuration,
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
    final data = <String, dynamic>{
      'name': name,
      'address': address,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'distance': distance,
      'duration': duration,
      'type': type,
      'imagePath': imagePath,
    };
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    return data;
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
