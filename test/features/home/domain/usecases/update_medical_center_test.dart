import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/update_medical_center.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldSucceed = true;
  MedicalCenterEntity? lastUpdatedCenter;

  @override
  Stream<List<BannerEntity>> getBannersStream() => const Stream.empty();

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() =>
      const Stream.empty();

  @override
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async {
    lastUpdatedCenter = center;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to update medical center'));
    }
  }
}

void main() {
  late FakeHomeRepository repository;
  late UpdateMedicalCenter usecase;

  setUp(() {
    repository = FakeHomeRepository();
    usecase = UpdateMedicalCenter(repository);
  });

  test('UpdateMedicalCenter returns SuccessAPI on success', () async {
    const center = MedicalCenterEntity(
      id: 'center_123',
      name: 'Sunrise Health Clinic',
      address: '123 Oak Street, CA 98765',
      rating: 4.9,
      reviewsCount: 58,
      distance: 2.5,
      duration: 40,
      type: 'Hospital',
      imagePath: 'assets/images/clinic1.png',
    );

    final result = await usecase(center);

    expect(result, isA<SuccessAPI<void>>());
    expect(repository.lastUpdatedCenter, equals(center));
  });

  test('UpdateMedicalCenter returns ErrorAPI on failure', () async {
    repository.shouldSucceed = false;

    const center = MedicalCenterEntity(
      id: 'center_123',
      name: 'Sunrise Health Clinic',
      address: '123 Oak Street, CA 98765',
      rating: 4.9,
      reviewsCount: 58,
      distance: 2.5,
      duration: 40,
      type: 'Hospital',
      imagePath: 'assets/images/clinic1.png',
    );

    final result = await usecase(center);

    expect(result, isA<ErrorAPI<void>>());
    final error = result as ErrorAPI<void>;
    expect(error.failure.message, 'Failed to update medical center');
  });
}
