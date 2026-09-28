import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medical_app/features/home/data/models/banner_model.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
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
}
