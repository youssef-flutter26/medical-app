import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    super.id,
    required super.name,
    required super.specialty,
    required super.categoryId,
    required super.categoryName,
    required super.experience,
    required super.rating,
    required super.reviewsCount,
    super.about = '',
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

  factory DoctorModel.fromFirestore(
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

    return DoctorModel(
      id: docId,
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      experience: _parseInt(json['experience']),
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(json['reviewsCount'] ?? json['reviewCount']),
      about: json['about']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'name': name,
      'specialty': specialty,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'experience': experience,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'about': about,
      'imagePath': imagePath,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
    return data;
  }

  factory DoctorModel.fromEntity(DoctorEntity entity) {
    return DoctorModel(
      id: entity.id,
      name: entity.name,
      specialty: entity.specialty,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      experience: entity.experience,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      about: entity.about,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
    );
  }
}
