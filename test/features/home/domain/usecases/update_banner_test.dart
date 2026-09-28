import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/update_banner.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldSucceed = true;
  BannerEntity? lastUpdatedBanner;

  @override
  Stream<List<BannerEntity>> getBannersStream() => const Stream.empty();

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() =>
      const Stream.empty();

  @override
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async {
    return const SuccessAPI(null);
  }

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async {
    lastUpdatedBanner = banner;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to update banner'));
    }
  }
}

void main() {
  late FakeHomeRepository repository;
  late UpdateBanner usecase;

  setUp(() {
    repository = FakeHomeRepository();
    usecase = UpdateBanner(repository);
  });

  test('UpdateBanner returns SuccessAPI on success', () async {
    const banner = BannerEntity(
      id: 'doc123',
      title: 'Updated Promo',
      description: 'Updated description',
      imagePath: 'assets/images/banner2.png',
    );

    final result = await usecase(banner);

    expect(result, isA<SuccessAPI<void>>());
    expect(repository.lastUpdatedBanner?.id, 'doc123');
    expect(repository.lastUpdatedBanner?.title, 'Updated Promo');
    expect(repository.lastUpdatedBanner?.description, 'Updated description');
    expect(repository.lastUpdatedBanner?.imagePath, 'assets/images/banner2.png');
  });

  test('UpdateBanner returns ErrorAPI on failure', () async {
    repository.shouldSucceed = false;

    const banner = BannerEntity(
      id: 'doc123',
      title: 'Error Promo',
      description: 'Will fail',
      imagePath: 'assets/images/fail.png',
    );

    final result = await usecase(banner);

    expect(result, isA<ErrorAPI<void>>());
  });
}
