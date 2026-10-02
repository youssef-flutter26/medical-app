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

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;
      final match = RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(trimmed);
      if (match != null) {
        return double.tryParse(match.group(0)!) ?? defaultValue;
      }
      return double.tryParse(trimmed) ?? defaultValue;
    }
    return defaultValue;
  }

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;
      final match = RegExp(r'[0-9]+').firstMatch(trimmed);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? defaultValue;
      }
      return int.tryParse(trimmed) ?? defaultValue;
    }
    return defaultValue;
  }

  factory MedicalCenterModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    DateTime? parsedCreatedAt;
    final rawCreatedAt = json['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    return MedicalCenterModel(
      id: docId,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(json['reviewsCount'] ?? json['reviewCount']),
      distance: _parseDouble(json['distance']),
      duration: _parseInt(json['duration']),
      type: json['type']?.toString() ??
          json['category']?.toString() ??
          'Hospital',
      imagePath: json['imagePath']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      createdAt: parsedCreatedAt,
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
