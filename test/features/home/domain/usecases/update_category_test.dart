import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/update_category.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldSucceed = true;
  CategoryEntity? lastUpdatedCategory;

  @override
  Stream<List<CategoryEntity>> getCategoriesStream() => const Stream.empty();

  @override
  Future<Result<void>> addCategory(CategoryEntity category) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateCategory(CategoryEntity category) async {
    lastUpdatedCategory = category;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to update category'));
    }
  }

  @override
  Stream<List<BannerEntity>> getBannersStream() => const Stream.empty();

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() =>
      const Stream.empty();

  @override
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async =>
      const SuccessAPI(null);
}

void main() {
  late FakeHomeRepository repository;
  late UpdateCategory usecase;

  setUp(() {
    repository = FakeHomeRepository();
    usecase = UpdateCategory(repository);
  });

  test('UpdateCategory returns SuccessAPI on success', () async {
    const category = CategoryEntity(
      id: 'cat123',
      name: 'Neurology',
      imagePath: 'assets/images/neurology.png',
    );

    final result = await usecase(category);

    expect(result, isA<SuccessAPI<void>>());
    expect(repository.lastUpdatedCategory?.id, 'cat123');
    expect(repository.lastUpdatedCategory?.name, 'Neurology');
    expect(
      repository.lastUpdatedCategory?.imagePath,
      'assets/images/neurology.png',
    );
  });

  test('UpdateCategory returns ErrorAPI on failure', () async {
    repository.shouldSucceed = false;

    const category = CategoryEntity(
      id: 'cat123',
      name: 'Cardiology',
      imagePath: 'assets/images/cardiology.png',
    );

    final result = await usecase(category);

    expect(result, isA<ErrorAPI<void>>());
  });
}
