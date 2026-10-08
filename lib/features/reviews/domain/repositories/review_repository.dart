import 'package:medical_app/core/error/result.dart';

import '../entities/review_entity.dart';
import '../entities/review_summary.dart';

abstract class ReviewRepository {
  Future<Result<List<ReviewEntity>>> getReviews({
    required String targetId,
    required String targetType,
  });

  Future<Result<ReviewEntity?>> getMyReview({
    required String targetId,
    required String targetType,
    required String userId,
  });

  Future<Result<void>> submitReview({required ReviewEntity review});

  Future<Result<ReviewSummary>> getReviewSummary({
    required String targetId,
    required String targetType,
  });

  Future<Result<List<ReviewEntity>>> getDoctorReviews({
    required String doctorId,
  });

  Future<Result<ReviewEntity?>> getMyDoctorReview({
    required String doctorId,
    required String userId,
  });

  Future<Result<void>> submitDoctorReview({required ReviewEntity review});
}
