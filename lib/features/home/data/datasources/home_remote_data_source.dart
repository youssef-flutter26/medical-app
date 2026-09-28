import 'package:medical_app/features/home/data/models/banner_model.dart';

abstract class HomeRemoteDataSource {
  Stream<List<BannerModel>> getBannersStream();
  Future<void> addBanner(BannerModel banner);
  Future<void> updateBanner(BannerModel banner);
}
