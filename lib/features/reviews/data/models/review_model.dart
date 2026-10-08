import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.targetId,
    required super.targetType,
    required super.userId,
    required super.userName,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    final targetId =
        json['targetId']?.toString() ?? json['doctorId']?.toString() ?? '';

    final targetType = json['targetType']?.toString() ?? 'doctor';

    return ReviewModel(
      id: docId ?? json['id']?.toString() ?? '',
      targetId: targetId,
      targetType: targetType,
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      rating: _parseDouble(json['rating']),
      comment: json['comment']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'targetId': targetId,
      'targetType': targetType,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    // Keep doctorId for old doctor reviews.
    if (targetType == 'doctor') {
      data['doctorId'] = targetId;
    }

    return data;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0.0;
    }

    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
