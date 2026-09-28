import 'package:medical_app/features/admin/data/models/banner_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> addBanner(BannerModel banner);
}
