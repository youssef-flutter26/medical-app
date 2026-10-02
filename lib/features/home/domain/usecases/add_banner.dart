import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class AddBanner {
  final HomeRepository repository;

  AddBanner(this.repository);

  Future<Result<void>> call(BannerEntity banner) {
    return repository.addBanner(banner);
  }
}
