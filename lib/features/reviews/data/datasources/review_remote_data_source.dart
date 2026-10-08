import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews({
    required String targetId,
    required String targetType,
  });

  Future<ReviewModel?> getMyReview({
    required String targetId,
    required String targetType,
    required String userId,
  });

  Future<void> submitReview({required ReviewModel review});

  Future<List<ReviewModel>> getDoctorReviews({required String doctorId});

  Future<ReviewModel?> getMyDoctorReview({
    required String doctorId,
    required String userId,
  });

  Future<void> submitDoctorReview({required ReviewModel review});
}
