import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class UpdateBanner {
  final HomeRepository repository;

  UpdateBanner(this.repository);

  Future<Result<void>> call(BannerEntity banner) {
    return repository.updateBanner(banner);
  }
}
