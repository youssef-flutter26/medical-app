import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/categories_section.dart';
import 'package:medical_app/features/home/presentation/widgets/category_item.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_centers_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssetLoader extends AssetLoader {
  const _FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "categories": "Categories",
      "nearbyMedicalCenters": "Nearby Medical Centers",
      "seeAll": "See All",
      "reviews": "Reviews",
      "contentNotFound": "Content not found",
      "noCategoriesFound": "No categories found",
    };
  }
}

final List<CategoryEntity> _twelveCategories = List.generate(
  12,
  (i) => CategoryEntity(id: 'cat_$i', name: 'Cat $i'),
);

final List<MedicalCenterEntity> _tenMedicalCenters = List.generate(
  10,
  (i) => MedicalCenterEntity(
    id: 'center_$i',
    name: 'Center $i',
    address: 'Address $i',
    rating: 4.5,
    reviewsCount: 50 + i,
    distance: 1.0 + i,
    duration: 10 + i,
    type: 'Clinic',
    imagePath: '',
  ),
);

Widget createHomePreviewTestWidget({
  VoidCallback? onCategorySeeAll,
  VoidCallback? onMedicalCenterSeeAll,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeAssetLoader(),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(1200, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    CategoriesSection(
                      categories: _twelveCategories.take(8).toList(),
                      onSeeAllPressed: onCategorySeeAll,
                    ),
                    MedicalCentersSection(
                      medicalCenters: _tenMedicalCenters.take(5).toList(),
                      onSeeAll: onMedicalCenterSeeAll,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('Home See All and Preview limits', () {
    testWidgets('displays only 8 preview categories on Home even when 12 exist',
        (tester) async {
      await tester.pumpWidget(createHomePreviewTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CategoryItem), findsNWidgets(8));
      expect(find.text('Cat 0'), findsOneWidget);
      expect(find.text('Cat 7'), findsOneWidget);
      expect(find.text('Cat 8'), findsNothing);
    });

    testWidgets('displays only 5 preview medical centers on Home even when 10 exist',
        (tester) async {
      tester.view.physicalSize = const Size(1500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createHomePreviewTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(MedicalCenterItem), findsNWidgets(5));
      expect(find.text('Center 0'), findsOneWidget);
      expect(find.text('Center 4'), findsOneWidget);
      expect(find.text('Center 5'), findsNothing);
    });

    testWidgets('triggers onSeeAllPressed callback when tapping See All on Categories',
        (tester) async {
      bool categorySeeAllTapped = false;
      await tester.pumpWidget(
        createHomePreviewTestWidget(
          onCategorySeeAll: () => categorySeeAllTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final seeAllButtons = find.text('See All');
      expect(seeAllButtons, findsNWidgets(2));

      // Tap first See All (Categories)
      await tester.tap(seeAllButtons.first);
      await tester.pumpAndSettle();

      expect(categorySeeAllTapped, isTrue);
    });

    testWidgets('triggers onSeeAll callback when tapping See All on Medical Centers',
        (tester) async {
      bool medicalCenterSeeAllTapped = false;
      await tester.pumpWidget(
        createHomePreviewTestWidget(
          onMedicalCenterSeeAll: () => medicalCenterSeeAllTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final seeAllButtons = find.text('See All');
      expect(seeAllButtons, findsNWidgets(2));

      // Tap second See All (Medical Centers)
      await tester.tap(seeAllButtons.last);
      await tester.pumpAndSettle();

      expect(medicalCenterSeeAllTapped, isTrue);
    });
  });
}
