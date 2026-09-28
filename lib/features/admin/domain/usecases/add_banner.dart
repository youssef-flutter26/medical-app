import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';
import 'package:medical_app/features/admin/domain/repositories/admin_repository.dart';

class AddBanner {
  final AdminRepository repository;

  AddBanner(this.repository);

  Future<Result<void>> call(BannerEntity banner) {
    return repository.addBanner(banner);
  }
}
