import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

import 'package:medical_app/features/home/domain/entities/category_entity.dart';

abstract class HomeRepository {
  Stream<List<BannerEntity>> getBannersStream();
  Future<Result<void>> addBanner(BannerEntity banner);
  Future<Result<void>> updateBanner(BannerEntity banner);
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream();
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center);
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center);
  Stream<List<CategoryEntity>> getCategoriesStream();
  Future<Result<void>> addCategory(CategoryEntity category);
  Future<Result<void>> updateCategory(CategoryEntity category);
}
