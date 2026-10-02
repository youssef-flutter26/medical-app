import 'package:medical_app/features/home/data/models/banner_model.dart';
import 'package:medical_app/features/home/data/models/category_model.dart';
import 'package:medical_app/features/home/data/models/medical_center_model.dart';

abstract class HomeRemoteDataSource {
  Stream<List<BannerModel>> getBannersStream();
  Future<void> addBanner(BannerModel banner);
  Future<void> updateBanner(BannerModel banner);
  Stream<List<MedicalCenterModel>> getMedicalCentersStream();
  Future<void> addMedicalCenter(MedicalCenterModel center);
  Future<void> updateMedicalCenter(MedicalCenterModel center);
  Stream<List<CategoryModel>> getCategoriesStream();
  Future<void> addCategory(CategoryModel category);
}
