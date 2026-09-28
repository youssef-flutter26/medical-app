import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:medical_app/features/admin/data/models/banner_model.dart';
import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';
import 'package:medical_app/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async {
    try {
      final model = BannerModel(
        title: banner.title,
        description: banner.description,
        imageUrl: banner.imageUrl,
      );
      await remoteDataSource.addBanner(model);
      return const SuccessAPI(null);
    } catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }
}
