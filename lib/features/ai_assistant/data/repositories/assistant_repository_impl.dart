import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/reviews/domain/repositories/review_repository.dart';

import '../../domain/entities/assistant_doctor.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_data_source.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._remoteDataSource,
      this._reviewRepository,);

  final AssistantRemoteDataSource _remoteDataSource;
  final ReviewRepository _reviewRepository;

  @override
  Future<List<AssistantDoctor>> searchNearbyDoctors({
    required double latitude,
    required double longitude,
    required String query,
    double radiusInKm = 15,
  }) async {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Invalid user coordinates.');
    }

    if (radiusInKm <= 0) {
      throw ArgumentError('Radius must be greater than zero.');
    }

    final documents = await _remoteDataSource.getDoctors();

    debugPrint('🩺 Doctors loaded from Firestore: ${documents.length}');

    final normalizedQuery = _normalize(query);
    final results = <AssistantDoctor>[];

    for (final data in documents) {
      final doctor = _mapDoctor(data);

      if (doctor.latitude == null || doctor.longitude == null) {
        debugPrint(
          '⚠️ Skipping doctor without coordinates: ${doctor.name}',
        );
        continue;
      }

      final distanceInMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        doctor.latitude!,
        doctor.longitude!,
      );

      final distanceInKm = distanceInMeters / 1000;

      if (distanceInKm > radiusInKm) {
        continue;
      }

      if (!_matchesQuery(doctor, normalizedQuery)) {
        continue;
      }

      // استخدام التقييمات الفعلية المحفوظة في reviews.
      double? rating = doctor.rating;
      int? reviewsCount = doctor.reviewsCount;

      debugPrint('⭐ Loading rating for: ${doctor.name}');
      debugPrint('⭐ Doctor document ID: ${doctor.id}');

      try {
        final summaryResult = await _reviewRepository.getReviewSummary(
          targetId: doctor.id,
          targetType: 'doctor',
        );

        switch (summaryResult) {
          case SuccessAPI(:final data):
            debugPrint(
              '⭐ Rating from reviews: ${data.rating}',
            );
            debugPrint(
              '⭐ Reviews count: ${data.reviewCount}',
            );

            if (data.reviewCount > 0) {
              rating = data.rating;
            } else {
              // لا توجد مراجعات؛ لا تعرض تقييمًا وهميًا.
              rating = null;
            }

            reviewsCount = data.reviewCount;

          case ErrorAPI(:final failure):
            debugPrint(
              '❌ Failed to load rating for ${doctor.id}: $failure',
            );

        // عند فشل تحميل المراجعات، نحتفظ بقيم بيانات الدكتور
        // كحل احتياطي.
        }
      } catch (e, stackTrace) {
        debugPrint(
          '❌ Exception loading rating for ${doctor.id}: $e',
        );
        debugPrint('$stackTrace');

        // لا نوقف البحث عن الدكاترة بسبب خطأ في التقييم.
      }

      results.add(
        AssistantDoctor(
          id: doctor.id,
          name: doctor.name,
          specialty: doctor.specialty,
          address: doctor.address,
          rating: rating,
          reviewsCount: reviewsCount,
          imageUrl: doctor.imageUrl,
          latitude: doctor.latitude,
          longitude: doctor.longitude,
          distanceInKm: distanceInKm,
          availableTime: doctor.availableTime,
          schedule: doctor.schedule,
        ),
      );
    }

    results.sort((a, b) {
      return a.distanceInKm!.compareTo(b.distanceInKm!);
    });

    debugPrint('🩺 Nearby doctors found: ${results.length}');

    return results;
  }

  AssistantDoctor _mapDoctor(Map<String, dynamic> data) {
    final rawSchedule = data['schedule'];

    return AssistantDoctor(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Unknown doctor',
      specialty: _firstString([
        data['specialty'],
        data['categoryName'],
      ]),
      address: _firstString([
        data['address'],
      ]),
      rating: _toDouble(data['rating']),
      reviewsCount: _toInt(
        data['reviewsCount'] ?? data['reviewCount'],
      ),
      imageUrl: _firstString([
        data['imageUrl'],
        data['imagePath'],
      ]),
      latitude: _toDouble(
        data['latitude'] ?? data['lat'],
      ),
      longitude: _toDouble(
        data['longitude'] ?? data['lng'] ?? data['lon'],
      ),
      availableTime: _firstString([
        data['availableTime'],
      ]),
      schedule: rawSchedule is Map
          ? Map<String, dynamic>.from(rawSchedule)
          : const <String, dynamic>{},
    );
  }

  bool _matchesQuery(AssistantDoctor doctor, String query) {
    if (query.isEmpty) return true;

    final searchableText = _normalize([
      doctor.name,
      doctor.specialty ?? '',
      doctor.address ?? '',
    ].join(' '));

    final keywords = query
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    return keywords.any(searchableText.contains);
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _firstString(List<dynamic> values) {
    for (final value in values) {
      if (value != null && value
          .toString()
          .trim()
          .isNotEmpty) {
        return value.toString().trim();
      }
    }

    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(
        value.trim().replaceAll(',', '.'),
      );
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  @override
  Future<String> sendMessage({
    required String message,
    required double latitude,
    required double longitude,
    required List<AssistantDoctor> nearbyDoctors,
  }) {
    return _remoteDataSource.sendMessage(
      message: message,
      latitude: latitude,
      longitude: longitude,
      nearbyDoctors: nearbyDoctors.map((doctor) {
        return {
          'id': doctor.id,
          'name': doctor.name,
          'specialty': doctor.specialty,
          'address': doctor.address,
          'rating': doctor.rating,
          'reviewsCount': doctor.reviewsCount,
          'imageUrl': doctor.imageUrl,
          'latitude': doctor.latitude,
          'longitude': doctor.longitude,
          'distanceInKm': doctor.distanceInKm,
          'availableTime': doctor.availableTime,
          'schedule': doctor.schedule,
        };
      }).toList(),
    );
  }
}
