import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/error/result.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/usecases/get_my_review.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/submit_review.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit({
    required this.getDoctorReviews,
    required this.getMyDoctorReview,
    required this.submitDoctorReview,
  }) : super(const ReviewState());

  final GetReviews getDoctorReviews;
  final GetMyReview getMyDoctorReview;
  final SubmitReview submitDoctorReview;

  Future<void> loadReviews({
    required String targetId,
    String targetType = 'doctor',
  }) async {
    emit(state.copyWith(status: ReviewStatus.loading, errorMessage: null));

    final result = await getDoctorReviews(
      targetId: targetId,
      targetType: targetType,
    );

    switch (result) {
      case SuccessAPI(:final data):
        emit(
          state.copyWith(
            status: ReviewStatus.success,
            reviews: data,
            errorMessage: null,
          ),
        );

      case ErrorAPI(:final failure):
        emit(
          state.copyWith(
            status: ReviewStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> loadMyReview({
    required String targetId,
    required String userId,
    String targetType = 'doctor',
  }) async {
    final result = await getMyDoctorReview(
      targetId: targetId,
      userId: userId,
      targetType: targetType,
    );

    switch (result) {
      case SuccessAPI(:final data):
        emit(state.copyWith(myReview: data, errorMessage: null));

      case ErrorAPI(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<bool> submitReview({required ReviewEntity review}) async {
    final result = await submitDoctorReview(review: review);

    switch (result) {
      case SuccessAPI():
        await loadReviews(
          targetId: review.targetId,
          targetType: review.targetType,
        );

        await loadMyReview(
          targetId: review.targetId,
          targetType: review.targetType,
          userId: review.userId,
        );

        return true;

      case ErrorAPI(:final failure):
        emit(
          state.copyWith(
            status: ReviewStatus.failure,
            errorMessage: failure.message,
          ),
        );

        return false;
    }
  }

  // Backward compatibility.
  Future<void> loadDoctorReviews({required String doctorId}) {
    return loadReviews(targetId: doctorId, targetType: 'doctor');
  }
}
