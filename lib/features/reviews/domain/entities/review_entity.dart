import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String targetId;
  final String targetType;

  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  String get doctorId => targetId;

  ReviewEntity copyWith({
    String? id,
    String? targetId,
    String? targetType,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    targetId,
    targetType,
    userId,
    userName,
    rating,
    comment,
    createdAt,
  ];
}
