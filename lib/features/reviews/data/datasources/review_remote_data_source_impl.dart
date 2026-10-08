import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/reviews/data/datasources/review_remote_data_source.dart';

import '../../../../core/error/app_exception.dart';
import '../models/review_model.dart';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  @override
  Future<List<ReviewModel>> getReviews({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final snapshot = await _reviewsCollection
          .where('targetId', isEqualTo: targetId)
          .get();

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .where((review) => review.targetType == targetType)
          .toList();

      if (targetType == 'doctor') {
        final oldSnapshot = await _reviewsCollection
            .where('doctorId', isEqualTo: targetId)
            .get();

        final existingIds = reviews.map((review) => review.id).toSet();

        for (final doc in oldSnapshot.docs) {
          if (existingIds.contains(doc.id)) {
            continue;
          }

          final review = ReviewModel.fromFirestore(doc.data(), doc.id);

          reviews.add(review);
        }
      }

      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load reviews.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReviewModel?> getMyReview({
    required String targetId,
    required String targetType,
    required String userId,
  }) async {
    try {
      final reviewId = '${targetId}_$userId';

      final doc = await _reviewsCollection.doc(reviewId).get();

      if (doc.exists && doc.data() != null) {
        final review = ReviewModel.fromFirestore(doc.data()!, doc.id);

        if (review.targetId == targetId && review.targetType == targetType) {
          return review;
        }
      }

      if (targetType == 'doctor') {
        final snapshot = await _reviewsCollection
            .where('doctorId', isEqualTo: targetId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final oldDoc = snapshot.docs.first;

          return ReviewModel.fromFirestore(oldDoc.data(), oldDoc.id);
        }
      }

      return null;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load your review.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> submitReview({required ReviewModel review}) async {
    try {
      final reviewId = '${review.targetId}_${review.userId}';

      await _reviewsCollection
          .doc(reviewId)
          .set(review.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to submit review.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ReviewModel>> getDoctorReviews({required String doctorId}) {
    return getReviews(targetId: doctorId, targetType: 'doctor');
  }

  @override
  Future<ReviewModel?> getMyDoctorReview({
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
  Future<void> submitDoctorReview({required ReviewModel review}) {
    return submitReview(review: review);
  }
}
