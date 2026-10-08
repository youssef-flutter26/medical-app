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
    super.availableTime = '',
    super.createdAt,
    super.latitude,
    super.longitude,
    super.schedule = const [],
  });

  static double _parseDouble(dynamic value, [
    double defaultValue = 0.0,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final trimmed = value.trim();

      if (trimmed.isEmpty) {
        return defaultValue;
      }

      return double.tryParse(
        trimmed.replaceAll(',', '.'),
      ) ??
          defaultValue;
    }

    return defaultValue;
  }

  static int _parseInt(dynamic value, [
    int defaultValue = 0,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final trimmed = value.trim();

      if (trimmed.isEmpty) {
        return defaultValue;
      }

      return int.tryParse(trimmed) ?? defaultValue;
    }

    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

  static List<DoctorSchedule> _parseSchedule(dynamic value,) {
    if (value is! Map) {
      return [];
    }

    final result = <DoctorSchedule>[];

    const days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];

    for (final day in days) {
      final rawDay = value[day];

      if (rawDay is Map) {
        result.add(
          DoctorSchedule(
            day: day,
            enabled: rawDay['enabled'] == true,
            startTime: rawDay['startTime']?.toString() ?? '',
            endTime: rawDay['endTime']?.toString() ?? '',
          ),
        );
      }
    }

    return result;
  }

  static Map<String, dynamic> _scheduleToFirestore(
      List<DoctorSchedule> schedule,) {
    final result = <String, dynamic>{};

    for (final item in schedule) {
      result[item.day] = {
        'enabled': item.enabled,
        'startTime': item.startTime,
        'endTime': item.endTime,
      };
    }

    return result;
  }

  factory DoctorModel.fromFirestore(Map<String, dynamic> json, [
    String? docId,
  ]) {
    DateTime? parsedCreatedAt =
    _parseDateTime(json['createdAt']);

    final parsedSchedule =
    _parseSchedule(json['schedule']);

    return DoctorModel(
      id: docId,
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ??
          json['categoryName']?.toString() ??
          '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName:
      json['categoryName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(
        json['reviewsCount'] ?? json['reviewCount'],
      ),
      imagePath:
      json['imagePath']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      availableTime: json['availableTime']?.toString() ?? '',
      createdAt: parsedCreatedAt,
      latitude: _parseNullableDouble(
        json['latitude'] ?? json['lat'],
      ),
      longitude: _parseNullableDouble(
        json['longitude'] ??
            json['lng'] ??
            json['lon'],
      ),
      schedule: parsedSchedule,
    );
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final trimmed = value.trim();

      if (trimmed.isEmpty) {
        return null;
      }

      return double.tryParse(
        trimmed.replaceAll(',', '.'),
      );
    }

    return null;
  }

  Map<String, dynamic> toFirestore({
    bool isNew = false,
  }) {
    return {
      'name': name,
      'specialty': specialty,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'address': address,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'availableTime': availableTime,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'schedule': _scheduleToFirestore(schedule),
      'createdAt': isNew || createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
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
      availableTime: entity.availableTime,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
      latitude: entity.latitude,
      longitude: entity.longitude,
      schedule: entity.schedule,
    );
  }
}