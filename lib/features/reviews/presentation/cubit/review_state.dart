import 'package:equatable/equatable.dart';

import '../../domain/entities/review_entity.dart';

enum ReviewStatus { initial, loading, success, failure }

class ReviewState extends Equatable {
  const ReviewState({
    this.status = ReviewStatus.initial,
    this.reviews = const [],
    this.myReview,
    this.errorMessage,
  });

  final ReviewStatus status;
  final List<ReviewEntity> reviews;
  final ReviewEntity? myReview;
  final String? errorMessage;

  double get averageRating {
    if (reviews.isEmpty) {
      return 0.0;
    }

    final total = reviews.fold<double>(
      0.0,
      (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  int get reviewsCount => reviews.length;

  ReviewState copyWith({
    ReviewStatus? status,
    List<ReviewEntity>? reviews,
    ReviewEntity? myReview,
    bool clearMyReview = false,
    String? errorMessage,
  }) {
    return ReviewState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      myReview: clearMyReview ? null : (myReview ?? this.myReview),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reviews, myReview, errorMessage];
}
