import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';

abstract class AdminRepository {
  Future<Result<void>> addBanner(BannerEntity banner);
}
