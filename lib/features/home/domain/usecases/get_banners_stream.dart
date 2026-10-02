import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class GetBannersStream {
  final HomeRepository repository;

  GetBannersStream(this.repository);

  Stream<List<BannerEntity>> call() {
    return repository.getBannersStream();
  }
}
