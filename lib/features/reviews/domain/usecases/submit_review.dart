import 'package:medical_app/core/error/result.dart';

import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class SubmitReview {
  SubmitReview(this.repository);

  final ReviewRepository repository;

  Future<Result<void>> call({required ReviewEntity review}) {
    return repository.submitReview(review: review);
  }
}
