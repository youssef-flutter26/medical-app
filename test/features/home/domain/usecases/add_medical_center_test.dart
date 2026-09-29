import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldSucceed = true;
  MedicalCenterEntity? lastAddedCenter;

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
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async {
    lastAddedCenter = center;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to add medical center'));
    }
  }

  @override
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async =>
      const SuccessAPI(null);
}

void main() {
  late FakeHomeRepository repository;
  late AddMedicalCenter usecase;

  setUp(() {
    repository = FakeHomeRepository();
    usecase = AddMedicalCenter(repository);
  });

  test('AddMedicalCenter returns SuccessAPI on success', () async {
    const center = MedicalCenterEntity(
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
    expect(repository.lastAddedCenter?.name, 'Sunrise Health Clinic');
    expect(repository.lastAddedCenter?.rating, 4.9);
    expect(repository.lastAddedCenter?.reviewsCount, 58);
    expect(repository.lastAddedCenter?.type, 'Hospital');
    expect(
      repository.lastAddedCenter?.imagePath,
      'assets/images/clinic1.png',
    );
  });

  test('AddMedicalCenter returns ErrorAPI on failure', () async {
    repository.shouldSucceed = false;

    const center = MedicalCenterEntity(
      name: 'Error Clinic',
      address: '123 Fake Street',
      rating: 3.0,
      reviewsCount: 10,
      distance: 1.0,
      duration: 10,
      type: 'Clinic',
      imagePath: 'assets/images/clinic2.png',
    );

    final result = await usecase(center);

    expect(result, isA<ErrorAPI<void>>());
  });
}
