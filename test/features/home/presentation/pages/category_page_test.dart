import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/category/presentation/pages/category_page.dart';
import 'package:medical_app/features/category/presentation/widgets/category_card.dart';
import 'package:medical_app/features/category/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/category/presentation/widgets/category_search_field.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssetLoader extends AssetLoader {
  const _FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "categories": "Categories",
      "allCategories": "All Categories",
      "searchCategory": "Search category...",
      "noCategoriesFound": "No categories found",
      "seeAll": "See All",
      "dentistry": "Dentistry",
      "cardiology": "Cardiology",
      "pulmonology": "Pulmonology",
      "general": "General",
      "neurology": "Neurology",
      "gastro": "Gastro...",
      "laboratory": "Laboratory",
      "vaccination": "Vaccination",
    };
  }
}

const _testCategories = [
  CategoryEntity(id: 'cat_1', name: 'Dentistry'),
  CategoryEntity(id: 'cat_2', name: 'Cardiology'),
  CategoryEntity(id: 'cat_3', name: 'Pulmonology'),
  CategoryEntity(id: 'cat_4', name: 'General'),
  CategoryEntity(id: 'cat_5', name: 'Neurology'),
  CategoryEntity(id: 'cat_6', name: 'Gastro...'),
  CategoryEntity(id: 'cat_7', name: 'Laboratory'),
  CategoryEntity(id: 'cat_8', name: 'Vaccination'),
];

Widget createCategoryPageTestWidget({
  ValueChanged<String>? onCategoryTap,
  Stream<List<CategoryEntity>>? categoriesStream,
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
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: CategoryPage(
              onCategoryTap: onCategoryTap,
              categoriesStream:
                  categoriesStream ?? Stream.value(_testCategories),
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

  group('CategoryPage widget tests', () {
    testWidgets('renders CategoryAppBar, CategorySearchField, and all category cards',
        (tester) async {
      await tester.pumpWidget(createCategoryPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('All Categories'), findsOneWidget);
      expect(find.byType(CategorySearchField), findsOneWidget);
      expect(find.byType(CategoryCard), findsNWidgets(8));
      expect(find.text('Dentistry'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Vaccination'), findsOneWidget);
    });

    testWidgets('filters category cards dynamically when searching',
        (tester) async {
      await tester.pumpWidget(createCategoryPageTestWidget());
      await tester.pumpAndSettle();

      // Enter search query "cardio"
      await tester.enterText(find.byType(TextField), 'cardio');
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCard), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Dentistry'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCard), findsNWidgets(8));
    });

    testWidgets('shows CategoryEmptyState when search has no matches',
        (tester) async {
      await tester.pumpWidget(createCategoryPageTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'NonExistentSpecialty');
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCard), findsNothing);
      expect(find.byType(CategoryEmptyState), findsOneWidget);
      expect(find.text('No categories found'), findsOneWidget);
    });

    testWidgets('invokes onCategoryTap callback when a category card is tapped',
        (tester) async {
      String? tappedCategory;
      await tester.pumpWidget(
        createCategoryPageTestWidget(
          onCategoryTap: (category) => tappedCategory = category,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dentistry'));
      await tester.pumpAndSettle();

      expect(tappedCategory, 'Dentistry');
    });
  });
}
