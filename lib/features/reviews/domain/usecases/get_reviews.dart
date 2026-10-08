import 'package:medical_app/core/error/result.dart';

import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetReviews {
  GetReviews(this.repository);

  final ReviewRepository repository;

  Future<Result<List<ReviewEntity>>> call({
    required String targetId,
    String targetType = 'doctor',
  }) {
    return repository.getReviews(targetId: targetId, targetType: targetType);
  }
}
