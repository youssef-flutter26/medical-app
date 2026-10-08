import 'package:medical_app/core/error/failure.dart';
import 'package:medical_app/core/error/result.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_summary.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._remoteDataSource);

  final ReviewRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ReviewEntity>>> getReviews({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final reviews = await _remoteDataSource.getReviews(
        targetId: targetId,
        targetType: targetType,
      );

      return SuccessAPI<List<ReviewEntity>>(reviews);
    } catch (e) {
      return ErrorAPI<List<ReviewEntity>>(_failureFromException(e));
    }
  }

  @override
  Future<Result<ReviewEntity?>> getMyReview({
    required String targetId,
    required String targetType,
    required String userId,
  }) async {
    try {
      final review = await _remoteDataSource.getMyReview(
        targetId: targetId,
        targetType: targetType,
        userId: userId,
      );

      return SuccessAPI<ReviewEntity?>(review);
    } catch (e) {
      return ErrorAPI<ReviewEntity?>(_failureFromException(e));
    }
  }

  @override
  Future<Result<void>> submitReview({required ReviewEntity review}) async {
    try {
      final model = ReviewModel(
        id: review.id,
        targetId: review.targetId,
        targetType: review.targetType,
        userId: review.userId,
        userName: review.userName,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
      );

      await _remoteDataSource.submitReview(review: model);

      return const SuccessAPI<void>(null);
    } catch (e) {
      return ErrorAPI<void>(_failureFromException(e));
    }
  }

  @override
  Future<Result<ReviewSummary>> getReviewSummary({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final reviews = await _remoteDataSource.getReviews(
        targetId: targetId,
        targetType: targetType,
      );

      if (reviews.isEmpty) {
        return const SuccessAPI<ReviewSummary>(
          ReviewSummary(rating: 0.0, reviewCount: 0),
        );
      }

      double totalRating = 0.0;

      for (final review in reviews) {
        totalRating += review.rating;
      }

      final averageRating = totalRating / reviews.length;

      return SuccessAPI<ReviewSummary>(
        ReviewSummary(rating: averageRating, reviewCount: reviews.length),
      );
    } catch (e) {
      return ErrorAPI<ReviewSummary>(_failureFromException(e));
    }
  }

  @override
  Future<Result<List<ReviewEntity>>> getDoctorReviews({
    required String doctorId,
  }) {
    return getReviews(targetId: doctorId, targetType: 'doctor');
  }

  @override
  Future<Result<ReviewEntity?>> getMyDoctorReview({
    required String doctorId,
    required String userId,
  }) {
    return getMyReview(
      targetId: doctorId,
      targetType: 'doctor',
      userId: userId,
    );
  }

  @override
  Future<Result<void>> submitDoctorReview({required ReviewEntity review}) {
    return submitReview(review: review);
  }

  Failure _failureFromException(Object error) {
    return UnknownFailure(error.toString());
  }
}
