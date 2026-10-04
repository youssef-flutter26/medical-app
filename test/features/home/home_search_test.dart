import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:medical_app/features/doctor/domain/usecases/get_doctors_stream.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/get_banners_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_medical_centers_stream.dart';
import 'package:medical_app/features/home/presentation/pages/home_screen.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search_results.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SearchTestAssetLoader extends AssetLoader {
  const _SearchTestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "location": "Location",
      "searchDoctor": "Search doctor...",
      "searchDoctorHint": "Search doctor...",
      "lookingForSpecialistDoctors": "Looking for\nSpecialist Doctors?",
      "bannerSubtext": "Schedule an appointment with our top doctors.",
      "explore": "Explore",
      "categories": "Categories",
      "seeAll": "See All",
      "category": "Category",
      "dentistry": "Dentistry",
      "cardiology": "Cardiology",
      "pulmonology": "Pulmonology",
      "general": "General",
      "neurology": "Neurology",
      "doctor": "Doctor",
      "allDoctors": "All Doctors",
      "medicalCenter": "Medical Center",
      "nearbyMedicalCenters": "Nearby Medical Centers",
      "contentNotFound": "Content not found",
      "reviews": "Reviews",
      "banner": "Banner",
    };
  }
}

class _FakeHomeRepo implements HomeRepository {
  final Stream<List<BannerEntity>> banners;
  final Stream<List<MedicalCenterEntity>> centers;
  final Stream<List<CategoryEntity>> categories;

  _FakeHomeRepo({
    required this.banners,
    required this.centers,
    required this.categories,
  });

  @override
  Stream<List<BannerEntity>> getBannersStream() => banners;

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() => centers;

  @override
  Stream<List<CategoryEntity>> getCategoriesStream() => categories;

  @override
  Future<Result<void>> addCategory(CategoryEntity category) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateCategory(CategoryEntity category) async =>
      const SuccessAPI(null);

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

class _FakeDoctorRepo implements DoctorRepository {
  final Stream<List<DoctorEntity>> doctors;

  _FakeDoctorRepo(this.doctors);

  @override
  Stream<List<DoctorEntity>> getDoctorsStream() => doctors;

  @override
  Stream<List<DoctorEntity>> getDoctorsByCategoryStream(String categoryId) =>
      doctors;

  @override
  Future<Result<void>> addDoctor(DoctorEntity doctor) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateDoctor(DoctorEntity doctor) async =>
      const SuccessAPI(null);
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  final testBanners = [
    const BannerEntity(
      id: 'banner_1',
      title: 'Meet Specialist Doctors Online',
      description: 'Schedule appointments quickly',
      imagePath: 'assets/images/banner1.png',
    ),
  ];

  final testCategories = [
    const CategoryEntity(id: 'cat_1', name: 'Dentistry'),
    const CategoryEntity(id: 'cat_2', name: 'Cardiology'),
    const CategoryEntity(id: 'cat_3', name: 'Pulmonology'),
  ];

  final testCenters = [
    const MedicalCenterEntity(
      id: 'center_1',
      name: 'Sunrise Health Clinic',
      address: '123 Oak Street, CA 98765',
      rating: 4.6,
      reviewsCount: 58,
      distance: 2.5,
      duration: 40,
      type: 'Hospital',
      imagePath: 'assets/images/clinic1.png',
    ),
    const MedicalCenterEntity(
      id: 'center_2',
      name: 'Golden Cardiology Center',
      address: '555 Pine Street, NY 10001',
      rating: 4.8,
      reviewsCount: 120,
      distance: 3.0,
      duration: 25,
      type: 'Clinic',
      imagePath: 'assets/images/clinic2.png',
    ),
  ];

  final testDoctors = [
    const DoctorEntity(
      id: 'doc_1',
      name: 'Dr. Ahmed Mahmoud',
      specialty: 'Cardiologist',
      categoryId: 'cat_2',
      categoryName: 'Cardiology',
      address: 'Cairo Clinic',
      rating: 4.9,
      reviewsCount: 150,
      imagePath: 'assets/images/doctor1.png',
    ),
    const DoctorEntity(
      id: 'doc_2',
      name: 'Dr. Sarah Connor',
      specialty: 'Dentist',
      categoryId: 'cat_1',
      categoryName: 'Dentistry',
      address: 'Dental Care Center',
      rating: 4.7,
      reviewsCount: 88,
      imagePath: 'assets/images/doctor2.png',
    ),
  ];

  Widget createWidget({TextEditingController? searchController}) {
    final homeRepo = _FakeHomeRepo(
      banners: Stream.value(testBanners),
      centers: Stream.value(testCenters),
      categories: Stream.value(testCategories),
    );
    final doctorRepo = _FakeDoctorRepo(Stream.value(testDoctors));

    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: const _SearchTestAssetLoader(),
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: AppScreenUtilScope(
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: HomeScreen(
              getBannersStream: GetBannersStream(homeRepo),
              getMedicalCentersStream: GetMedicalCentersStream(homeRepo),
              getCategoriesStream: GetCategoriesStream(homeRepo),
              getDoctorsStream: GetDoctorsStream(doctorRepo),
              searchController: searchController,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Global search matches doctor name (e.g. "Ahmed")',
      (WidgetTester tester) async {
    final searchController = TextEditingController();
    await tester.pumpWidget(createWidget(searchController: searchController));
    await tester.pumpAndSettle();

    searchController.text = 'Ahmed';
    await tester.pumpAndSettle();

    expect(find.byType(HomeSearchResults), findsOneWidget);
    expect(find.text('Dr. Ahmed Mahmoud'), findsOneWidget);
    expect(find.text('Dr. Sarah Connor'), findsNothing);
  });

  testWidgets('Global search matches category name (e.g. "dent" -> "Dentistry")',
      (WidgetTester tester) async {
    final searchController = TextEditingController();
    await tester.pumpWidget(createWidget(searchController: searchController));
    await tester.pumpAndSettle();

    searchController.text = 'dent';
    await tester.pumpAndSettle();

    expect(find.byType(HomeSearchResults), findsOneWidget);
    expect(find.text('Dentistry'), findsOneWidget);
    expect(find.text('Dr. Sarah Connor'), findsOneWidget);
    expect(find.text('Dr. Ahmed Mahmoud'), findsNothing);
  });

  testWidgets(
      'Global search matches medical center name (e.g. "Sunrise")',
      (WidgetTester tester) async {
    final searchController = TextEditingController();
    await tester.pumpWidget(createWidget(searchController: searchController));
    await tester.pumpAndSettle();

    searchController.text = 'Sunrise';
    await tester.pumpAndSettle();

    expect(find.byType(HomeSearchResults), findsOneWidget);
    expect(find.text('Sunrise Health Clinic'), findsOneWidget);
    expect(find.text('Golden Cardiology Center'), findsNothing);
  });

  testWidgets(
      'Global search recognizes section query "nearby medical centers"',
      (WidgetTester tester) async {
    final searchController = TextEditingController();
    await tester.pumpWidget(createWidget(searchController: searchController));
    await tester.pumpAndSettle();

    searchController.text = 'nearby medical centers';
    await tester.pumpAndSettle();

    expect(find.byType(HomeSearchResults), findsOneWidget);
    expect(find.text('Sunrise Health Clinic'), findsOneWidget);
    expect(find.text('Golden Cardiology Center'), findsOneWidget);
  });

  testWidgets('Global search shows empty state when no results match',
      (WidgetTester tester) async {
    final searchController = TextEditingController();
    await tester.pumpWidget(createWidget(searchController: searchController));
    await tester.pumpAndSettle();

    searchController.text = 'unknown_random_query_xyz';
    await tester.pumpAndSettle();

    expect(find.byType(HomeSearchResults), findsOneWidget);
    expect(find.text('Content not found'), findsOneWidget);
    expect(find.text('Dr. Ahmed Mahmoud'), findsNothing);
    expect(find.text('Dentistry'), findsNothing);
  });
}
