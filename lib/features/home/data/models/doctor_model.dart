import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    super.id,
    required super.name,
    required super.specialty,
    required super.categoryId,
    required super.categoryName,
    super.address = '',
    required super.rating,
    required super.reviewsCount,
    required super.imagePath,
    super.availableTime = 'Mon - Sat: 09:00 AM - 05:00 PM',
    super.createdAt,
    super.latitude,
    super.longitude,
  });

  static double _parseDouble(dynamic value, [
    double defaultValue = 0.0,
  ]) {
    if (value == null) return defaultValue;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final normalized =
      value.trim().replaceAll(',', '.');

      if (normalized.isEmpty) {
        return defaultValue;
      }

      final parsed = double.tryParse(normalized);

      if (parsed != null) {
        return parsed;
      }

      final match = RegExp(
        r'-?[0-9]+(?:\.[0-9]+)?',
      ).firstMatch(normalized);

      if (match != null) {
        return double.tryParse(
          match.group(0)!,
        ) ??
            defaultValue;
      }
    }

    return defaultValue;
  }

  static double? _parseNullableDouble(dynamic value,) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final normalized =
      value.trim().replaceAll(',', '.');

      if (normalized.isEmpty) return null;

      return double.tryParse(normalized);
    }

    return null;
  }

  static int _parseInt(dynamic value, [
    int defaultValue = 0,
  ]) {
    if (value == null) return defaultValue;

    if (value is int) return value;

    if (value is num) return value.toInt();

    if (value is String) {
      final trimmed = value.trim();

      if (trimmed.isEmpty) return defaultValue;

      final parsed = int.tryParse(trimmed);

      if (parsed != null) {
        return parsed;
      }

      final match = RegExp(
        r'-?[0-9]+',
      ).firstMatch(trimmed);

      if (match != null) {
        return int.tryParse(
          match.group(0)!,
        ) ??
            defaultValue;
      }
    }

    return defaultValue;
  }

  factory DoctorModel.fromFirestore(Map<String, dynamic> json, [
    String? docId,
  ]) {
    DateTime? parsedCreatedAt;

    final rawCreatedAt = json['createdAt'];

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(
        rawCreatedAt,
      );
    } else if (rawCreatedAt is int) {
      parsedCreatedAt =
          DateTime.fromMillisecondsSinceEpoch(
            rawCreatedAt,
          );
    }

    return DoctorModel(
      id: docId,
      name: json['name']?.toString() ?? '',
      specialty:
      json['specialty']?.toString() ?? '',
      categoryId:
      json['categoryId']?.toString() ?? '',
      categoryName:
      json['categoryName']?.toString() ?? '',
      address:
      json['address']?.toString() ??
          json['location']?.toString() ??
          '',
      rating: _parseDouble(
        json['rating'],
      ),
      reviewsCount: _parseInt(
        json['reviewsCount'] ??
            json['reviewCount'],
      ),
      imagePath:
      json['imagePath']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      availableTime:
      json['availableTime']?.toString() ??
          json['schedule']?.toString() ??
          'Mon - Sat: 09:00 AM - 05:00 PM',
      createdAt: parsedCreatedAt,
      latitude: _parseNullableDouble(
        json['latitude'] ?? json['lat'],
      ),
      longitude: _parseNullableDouble(
        json['longitude'] ??
            json['lng'] ??
            json['lon'],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'name': name,
      'specialty': specialty,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'address': address,
      'location': address,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'imagePath': imagePath,
      'availableTime': availableTime,
      'schedule': availableTime,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };

    if (latitude != null) {
      data['latitude'] = latitude;
    }

    if (longitude != null) {
      data['longitude'] = longitude;
    }

    return data;
  }

  factory DoctorModel.fromEntity(DoctorEntity entity,) {
    return DoctorModel(
      id: entity.id,
      name: entity.name,
      specialty: entity.specialty,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      address: entity.address,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      imagePath: entity.imagePath,
      availableTime: entity.availableTime,
      createdAt: entity.createdAt,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}