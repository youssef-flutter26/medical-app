import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';
import 'package:medical_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:medical_app/features/admin/domain/usecases/add_banner.dart';

class FakeAdminRepository implements AdminRepository {
  bool shouldSucceed = true;
  BannerEntity? lastAddedBanner;

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async {
    lastAddedBanner = banner;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to add banner'));
    }
  }
}

void main() {
  late FakeAdminRepository repository;
  late AddBanner usecase;

  setUp(() {
    repository = FakeAdminRepository();
    usecase = AddBanner(repository);
  });

  test('AddBanner returns SuccessAPI on success', () async {
    const banner = BannerEntity(
      title: 'Summer Promo',
      description: 'Book today',
      imageUrl: 'https://example.com/banner.jpg',
    );

    final result = await usecase(banner);

    expect(result, isA<SuccessAPI<void>>());
    expect(repository.lastAddedBanner?.title, 'Summer Promo');
    expect(repository.lastAddedBanner?.description, 'Book today');
    expect(repository.lastAddedBanner?.imageUrl, 'https://example.com/banner.jpg');
  });

  test('AddBanner returns ErrorAPI on failure', () async {
    repository.shouldSucceed = false;

    const banner = BannerEntity(
      title: 'Error Promo',
      description: 'Will fail',
      imageUrl: 'https://example.com/fail.jpg',
    );

    final result = await usecase(banner);

    expect(result, isA<ErrorAPI<void>>());
  });
}
