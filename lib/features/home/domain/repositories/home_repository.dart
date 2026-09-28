import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';

abstract class HomeRepository {
  Stream<List<BannerEntity>> getBannersStream();
  Future<Result<void>> addBanner(BannerEntity banner);
  Future<Result<void>> updateBanner(BannerEntity banner);
}
