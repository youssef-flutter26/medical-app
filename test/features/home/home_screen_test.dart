import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/get_banners_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_medical_centers_stream.dart';
import 'package:medical_app/features/home/presentation/pages/home_screen.dart';
import 'package:medical_app/features/home/presentation/widgets/category_item.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner_slider.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTestAssetLoader extends AssetLoader {
  const HomeTestAssetLoader();

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
      "dentistry": "Dentistry",
      "cardiology": "Cardiology",
      "pulmonology": "Pulmonology",
      "general": "General",
      "neurology": "Neurology",
      "gastro": "Gastro...",
      "laboratory": "Laboratory",
      "vaccination": "Vaccination",
      "nearbyMedicalCenters": "Nearby Medical Centers",
      "contentNotFound": "Content not found",
      "noCategoriesFound": "No categories found",
    };
  }
}

Widget createHomeScreenTestWidget({
  GetMedicalCentersStream? getMedicalCentersStream,
  GetCategoriesStream? getCategoriesStream,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const HomeTestAssetLoader(),
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: AppScreenUtilScope(
      child: Builder(
        builder: (context) => _buildMaterialApp(
          context,
          getMedicalCentersStream: getMedicalCentersStream,
          getCategoriesStream: getCategoriesStream,
        ),
      ),
    ),
  );
}

Widget _buildMaterialApp(
  BuildContext context, {
  GetMedicalCentersStream? getMedicalCentersStream,
  GetCategoriesStream? getCategoriesStream,
}) {
  return MaterialApp(
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    home: HomeScreen(
      getMedicalCentersStream: getMedicalCentersStream,
      getCategoriesStream: getCategoriesStream,
    ),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('HomeScreen renders all sections in the correct order', (
    WidgetTester tester,
  ) async {
    final centers = [
      const MedicalCenterEntity(
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
    final categories = [
      const CategoryEntity(name: 'Pediatrics'),
      const CategoryEntity(name: 'Cardiology'),
      const CategoryEntity(name: 'Pulmonology'),
      const CategoryEntity(name: 'General'),
      const CategoryEntity(name: 'Neurology'),
      const CategoryEntity(name: 'Gastro...'),
      const CategoryEntity(name: 'Laboratory'),
      const CategoryEntity(name: 'Vaccination'),
    ];
    final fakeRepo = _FakeHomeRepository(
      const Stream.empty(),
      Stream.value(centers),
      Stream.value(categories),
    );
    final getCentersStream = GetMedicalCentersStream(fakeRepo);
    final getCategoriesStream = GetCategoriesStream(fakeRepo);

    await tester.pumpWidget(createHomeScreenTestWidget(
      getMedicalCentersStream: getCentersStream,
      getCategoriesStream: getCategoriesStream,
    ));
    await tester.pumpAndSettle();

    // 1. Location section
    expect(find.byType(HomeLocation), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Seattle, USA'), findsOneWidget);

    // 2. Search section
    expect(find.byType(HomeSearch), findsOneWidget);
    expect(find.text('Search doctor...'), findsOneWidget);

    // 3. Banner section
    expect(find.byType(HomeBanner), findsOneWidget);
    expect(find.text('Looking for\nSpecialist Doctors?'), findsOneWidget);

    // 4. Categories section
    expect(find.byType(HomeCategories), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.byType(CategoryItem), findsNWidgets(8));
    expect(find.text('Pediatr..'), findsOneWidget);
    expect(find.text('Dentist'), findsNothing);
    expect(find.text('Dentistry'), findsNothing);
    expect(find.text('Cardiol..'), findsOneWidget);
    expect(find.text('Pulmono..'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Neurology'), findsOneWidget);
    expect(find.text('Gastro...'), findsOneWidget);
    expect(find.text('Laborat..'), findsOneWidget);
    expect(find.text('Vaccina..'), findsOneWidget);

    // 5. Nearby Medical Centers section
    expect(find.byType(NearbyMedicalCenters), findsOneWidget);
    expect(find.text('Nearby Medical Centers'), findsOneWidget);
    expect(find.byType(MedicalCenterItem), findsNWidgets(2));
    expect(find.text('Sunrise Health Clinic'), findsOneWidget);
    expect(find.text('Golden Cardiology Center'), findsOneWidget);
  });

  testWidgets('HomeScreen renders empty state when no medical centers exist in stream', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomeScreenTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(NearbyMedicalCenters), findsOneWidget);
    expect(find.text('Nearby Medical Centers'), findsOneWidget);
    expect(find.byType(MedicalCenterItem), findsNothing);
    expect(find.text('Content not found'), findsOneWidget);
  });

  testWidgets(
      'HomeBanner displays banner image as background using DecorationImage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeBanner(
                title: 'Meet Doctors Online',
                subtitle: 'Book an appointment with your doctor',
                imagePath: 'assets/images/banner1.png',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meet Doctors Online'), findsOneWidget);
    expect(find.text('Book an appointment with your doctor'), findsOneWidget);

    // Image must NOT be a separate Image.asset widget
    expect(find.byType(Image), findsNothing);

    // Image must be applied as background DecorationImage
    final containerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).image != null,
    );
    expect(containerFinder, findsOneWidget);

    final containerWidget = tester.widget<Container>(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration;
    expect(decoration.image?.image, isA<AssetImage>());
    expect(
      (decoration.image!.image as AssetImage).assetName,
      'assets/images/banner1.png',
    );
    expect(decoration.image?.fit, BoxFit.cover);

    // Verify _1 and _2 blur background layers are present
    expect(find.byType(SvgPicture), findsNWidgets(2));

    // Verify page indicator dots
    expect(find.byType(AnimatedSmoothIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen renders banners dynamically from GetBannersStream', (
    WidgetTester tester,
  ) async {
    final banners = [
      const BannerEntity(
        id: '1',
        title: 'Meet Doctors Online',
        description: 'Book an appointment with your doctor',
        imagePath: 'assets/images/banner1.png',
      ),
    ];
    final fakeRepo = _FakeHomeRepository(Stream.value(banners));
    final getBannersStream = GetBannersStream(fakeRepo);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: MaterialApp(
            home: HomeScreen(getBannersStream: getBannersStream),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meet Doctors Online'), findsOneWidget);
    expect(find.text('Book an appointment with your doctor'), findsOneWidget);

    // No separate Image widget inside HomeBanner
    expect(
      find.descendant(
        of: find.byType(HomeBanner),
        matching: find.byType(Image),
      ),
      findsNothing,
    );

    // Applied as background DecorationImage inside HomeBanner
    final containerFinder = find.descendant(
      of: find.byType(HomeBanner),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).image != null,
      ),
    );
    expect(containerFinder, findsOneWidget);

    final containerWidget = tester.widget<Container>(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration;
    expect(decoration.image?.image, isA<AssetImage>());
    expect(
      (decoration.image!.image as AssetImage).assetName,
      'assets/images/banner1.png',
    );
    expect(decoration.image?.fit, BoxFit.cover);

    // Verify _1 and _2 blur background layers are present inside HomeBanner
    expect(
      find.descendant(
        of: find.byType(HomeBanner),
        matching: find.byType(SvgPicture),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets(
      'HomeBanner displays edit pencil icon for Admin and hides it for normal users',
      (WidgetTester tester) async {
    bool editTapped = false;

    // 1. Normal user (isAdmin = false)
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeBanner(
                title: 'User Banner',
                subtitle: 'User Description',
                imagePath: 'assets/images/banner1.png',
                isAdmin: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Normal users must NOT see edit controls
    expect(find.byKey(const Key('banner_edit_button')), findsNothing);

    // 2. Admin user (isAdmin = true with onEdit callback)
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeBanner(
                title: 'Admin Banner',
                subtitle: 'Admin Description',
                imagePath: 'assets/images/banner1.png',
                isAdmin: true,
                onEdit: () {
                  editTapped = true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Admin MUST see the edit pencil icon
    expect(find.byKey(const Key('banner_edit_button')), findsOneWidget);

    // Tapping triggers onEdit
    await tester.tap(find.byKey(const Key('banner_edit_button')));
    await tester.pumpAndSettle();
    expect(editTapped, isTrue);
  });

  testWidgets(
      'MedicalCenterItem displays edit pencil icon for Admin and hides it for normal users',
      (WidgetTester tester) async {
    bool editTapped = false;

    // 1. Normal user (isAdmin = false)
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: MedicalCenterItem(
                name: 'Sunrise Health Clinic',
                address: '123 Oak St',
                rating: 4.6,
                reviewCount: 58,
                distance: '2.5 km',
                duration: '40 min',
                isAdmin: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Normal users must NOT see edit controls
    expect(find.byKey(const Key('medical_center_edit_button')), findsNothing);

    // 2. Admin user (isAdmin = true with onEdit callback)
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: MedicalCenterItem(
                name: 'Sunrise Health Clinic',
                address: '123 Oak St',
                rating: 4.6,
                reviewCount: 58,
                distance: '2.5 km',
                duration: '40 min',
                isAdmin: true,
                onEdit: () {
                  editTapped = true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Admin MUST see the edit pencil icon
    expect(find.byKey(const Key('medical_center_edit_button')), findsOneWidget);

    // Tapping triggers onEdit
    await tester.tap(find.byKey(const Key('medical_center_edit_button')));
    await tester.pumpAndSettle();
    expect(editTapped, isTrue);
  });

  testWidgets(
      'HomeBanner converts literal \\n in title and description to actual newlines',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeBanner(
                title: r'Looking for\nSpecialist Doctors?',
                subtitle: r'Book with\ntop doctors.',
                imagePath: 'assets/images/banner1.png',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Looking for\nSpecialist Doctors?"), findsOneWidget);
    expect(find.text("Book with\ntop doctors."), findsOneWidget);
  });

  testWidgets(
      'HomeBannerSlider auto-plays banners smoothly at interval and loops',
      (WidgetTester tester) async {
    final banners = [
      const BannerEntity(
        id: '1',
        title: 'Banner 1',
        description: 'Desc 1',
        imagePath: 'assets/images/banner1.png',
      ),
      const BannerEntity(
        id: '2',
        title: 'Banner 2',
        description: 'Desc 2',
        imagePath: 'assets/images/banner2.png',
      ),
    ];

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeBannerSlider(
                banners: banners,
                autoPlayInterval: const Duration(seconds: 4),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Banner 1'), findsOneWidget);

    // Advance 4 seconds and pump animation
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Banner 2 should now be visible
    expect(find.text('Banner 2'), findsOneWidget);

    // Advance another 4 seconds to verify looping
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Loops back to Banner 1
    expect(find.text('Banner 1'), findsOneWidget);
  });

  testWidgets(
      'Home Categories displays empty state and never shows Dentist when Firestore stream is empty',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = _FakeHomeRepository(
      const Stream.empty(),
      const Stream.empty(),
      Stream.value(const <CategoryEntity>[]),
    );
    final getCentersStream = GetMedicalCentersStream(fakeRepo);
    final getCategoriesStream = GetCategoriesStream(fakeRepo);

    await tester.pumpWidget(createHomeScreenTestWidget(
      getMedicalCentersStream: getCentersStream,
      getCategoriesStream: getCategoriesStream,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(HomeCategories), findsOneWidget);
    expect(find.text('No categories found'), findsOneWidget);
    expect(find.byType(CategoryItem), findsNothing);
    expect(find.text('Dentist'), findsNothing);
    expect(find.text('Dentistry'), findsNothing);
  });

  testWidgets(
      'Home Categories displays ONLY categories emitted from Firestore stream',
      (tester) async {
    final categories = [
      const CategoryEntity(name: 'General'),
      const CategoryEntity(name: 'Neurology'),
    ];
    final fakeRepo = _FakeHomeRepository(
      const Stream.empty(),
      const Stream.empty(),
      Stream.value(categories),
    );
    final getCentersStream = GetMedicalCentersStream(fakeRepo);
    final getCategoriesStream = GetCategoriesStream(fakeRepo);

    await tester.pumpWidget(createHomeScreenTestWidget(
      getMedicalCentersStream: getCentersStream,
      getCategoriesStream: getCategoriesStream,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryItem), findsNWidgets(2));
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Neurology'), findsOneWidget);
    expect(find.text('Dentist'), findsNothing);
    expect(find.text('Dentistry'), findsNothing);
  });

  testWidgets(
      'CategoryItem displays edit pencil icon for Admin and hides it for normal users',
      (WidgetTester tester) async {
    bool editTapped = false;

    // 1. Normal user (isAdmin = false)
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: CategoryItem(
                title: 'Cardiology',
                icon: Icons.favorite,
                isAdmin: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Normal users must NOT see edit controls
    expect(find.byKey(const Key('category_edit_button')), findsNothing);

    // 2. Admin user (isAdmin = true with onEdit callback)
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: CategoryItem(
                title: 'Cardiology',
                icon: Icons.favorite,
                isAdmin: true,
                onEdit: () {
                  editTapped = true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Admin MUST see the edit pencil icon
    expect(find.byKey(const Key('category_edit_button')), findsOneWidget);

    // Tapping triggers onEdit
    await tester.tap(find.byKey(const Key('category_edit_button')));
    await tester.pumpAndSettle();
    expect(editTapped, isTrue);
  });

  testWidgets(
      'HomeCategories passes onEditCategory callback with category entity',
      (WidgetTester tester) async {
    CategoryEntity? editedCategory;
    final categories = [
      const CategoryEntity(id: 'cat_1', name: 'Cardiology'),
      const CategoryEntity(id: 'cat_2', name: 'Dermatology'),
    ];

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const HomeTestAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeCategories(
                categories: categories,
                isAdmin: true,
                onEditCategory: (category) {
                  editedCategory = category;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category_edit_button')), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('category_edit_button')).first);
    await tester.pumpAndSettle();

    expect(editedCategory?.id, equals('cat_1'));
    expect(editedCategory?.name, equals('Cardiology'));
  });
}

class _FakeHomeRepository implements HomeRepository {
  final Stream<List<BannerEntity>> _stream;
  final Stream<List<MedicalCenterEntity>> _medicalCentersStream;
  final Stream<List<CategoryEntity>> _categoriesStream;

  _FakeHomeRepository(
    this._stream, [
    this._medicalCentersStream = const Stream.empty(),
    this._categoriesStream = const Stream.empty(),
  ]);

  @override
  Stream<List<BannerEntity>> getBannersStream() => _stream;

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() =>
      _medicalCentersStream;

  @override
  Stream<List<CategoryEntity>> getCategoriesStream() => _categoriesStream;

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

