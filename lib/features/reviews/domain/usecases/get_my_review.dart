import 'package:medical_app/core/error/result.dart';

import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetMyReview {
  GetMyReview(this.repository);

  final ReviewRepository repository;

  Future<Result<ReviewEntity?>> call({
    required String targetId,
    required String userId,
    String targetType = 'doctor',
  }) {
    return repository.getMyReview(
      targetId: targetId,
      targetType: targetType,
      userId: userId,
    );
  }
}
