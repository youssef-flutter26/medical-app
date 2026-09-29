import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/add_banner.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldSucceed = true;
  BannerEntity? lastAddedBanner;

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
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async {
    return const SuccessAPI(null);
  }

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async {
    lastAddedBanner = banner;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to add banner'));
    }
  }

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async {
    lastAddedBanner = banner;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to update banner'));
    }
  }
}

void main() {
  late FakeHomeRepository repository;
  late AddBanner usecase;

  setUp(() {
    repository = FakeHomeRepository();
    usecase = AddBanner(repository);
  });

  test('AddBanner returns SuccessAPI on success', () async {
    const banner = BannerEntity(
      title: 'Summer Promo',
      description: 'Book today',
      imagePath: 'assets/images/banner1.png',
    );

    final result = await usecase(banner);

    expect(result, isA<SuccessAPI<void>>());
    expect(repository.lastAddedBanner?.title, 'Summer Promo');
    expect(repository.lastAddedBanner?.description, 'Book today');
    expect(repository.lastAddedBanner?.imagePath, 'assets/images/banner1.png');
  });

  test('AddBanner returns ErrorAPI on failure', () async {
    repository.shouldSucceed = false;

    const banner = BannerEntity(
      title: 'Error Promo',
      description: 'Will fail',
      imagePath: 'assets/images/fail.png',
    );

    final result = await usecase(banner);

    expect(result, isA<ErrorAPI<void>>());
  });
}
