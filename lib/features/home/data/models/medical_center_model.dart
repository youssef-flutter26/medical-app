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
    final String distanceStr;
    if (rawDistance is num) {
      final d = rawDistance.toDouble();
      distanceStr = d == d.roundToDouble() ? '${d.toInt()} km' : '$d km';
    } else if (rawDistance is String && rawDistance.isNotEmpty) {
      distanceStr = rawDistance.contains('km') ? rawDistance : '$rawDistance km';
    } else {
      distanceStr = '';
    }

    final rawDuration = json['duration'];
    final String durationStr;
    if (rawDuration is num) {
      durationStr = '${rawDuration.toInt()} min';
    } else if (rawDuration is String && rawDuration.isNotEmpty) {
      durationStr = rawDuration.contains('min') ? rawDuration : '$rawDuration min';
    } else {
      durationStr = '';
    }

    return MedicalCenterModel(
      id: docId,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
      distance: distanceStr,
      duration: durationStr,
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
    double distanceNum = 0.0;
    final distMatch = RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(distance);
    if (distMatch != null) {
      distanceNum = double.tryParse(distMatch.group(0)!) ?? 0.0;
    }

    int durationNum = 0;
    final durMatch = RegExp(r'[0-9]+').firstMatch(duration);
    if (durMatch != null) {
      durationNum = int.tryParse(durMatch.group(0)!) ?? 0;
    }

    final data = <String, dynamic>{
      'name': name,
      'address': address,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'distance': distanceNum,
      'duration': durationNum,
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
