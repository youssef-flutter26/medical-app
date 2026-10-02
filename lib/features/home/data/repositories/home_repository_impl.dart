import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medical_app/features/home/data/models/banner_model.dart';
import 'package:medical_app/features/home/data/models/medical_center_model.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<BannerEntity>> getBannersStream() {
    return remoteDataSource.getBannersStream().map(
          (models) => models
              .map(
                (model) => BannerEntity(
                  id: model.id,
                  title: model.title,
                  description: model.description,
                  imagePath: model.imagePath,
                  createdAt: model.createdAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async {
    try {
      final model = BannerModel.fromEntity(banner);
      await remoteDataSource.addBanner(model);
      return const SuccessAPI(null);
    } catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async {
    try {
      final model = BannerModel.fromEntity(banner);
      await remoteDataSource.updateBanner(model);
      return const SuccessAPI(null);
    } catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() {
    return remoteDataSource.getMedicalCentersStream().map(
          (models) => models.cast<MedicalCenterEntity>().toList(),
        );
  }

  @override
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async {
    try {
      final model = MedicalCenterModel.fromEntity(center);
      await remoteDataSource.addMedicalCenter(model);
      return const SuccessAPI(null);
    } on FirebaseException catch (e) {
      debugPrint(
        'HomeRepository addMedicalCenter FirebaseException: [${e.code}] ${e.message}',
      );
      return ErrorAPI(FirebaseFailure.fromException(e));
    } catch (e) {
      debugPrint('HomeRepository addMedicalCenter error: $e');
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }

  @override
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async {
    try {
      final model = MedicalCenterModel.fromEntity(center);
      await remoteDataSource.updateMedicalCenter(model);
      return const SuccessAPI(null);
    } on FirebaseException catch (e) {
      debugPrint(
        'HomeRepository updateMedicalCenter FirebaseException: [${e.code}] ${e.message}',
      );
      return ErrorAPI(FirebaseFailure.fromException(e));
    } catch (e) {
      debugPrint('HomeRepository updateMedicalCenter error: $e');
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }
}
