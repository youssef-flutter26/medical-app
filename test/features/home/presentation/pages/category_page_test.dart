import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/home/presentation/pages/category_page.dart';
import 'package:medical_app/features/home/presentation/widgets/category_card.dart';
import 'package:medical_app/features/home/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/home/presentation/widgets/category_list_view.dart';
import 'package:medical_app/features/home/presentation/widgets/category_search_field.dart';
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
  bool? isAdmin,
  ui.TextDirection textDirection = ui.TextDirection.ltr,
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
            home: Directionality(
              textDirection: textDirection,
              child: CategoryPage(
                onCategoryTap: onCategoryTap,
                isAdmin: isAdmin,
                categoriesStream:
                    categoriesStream ?? Stream.value(_testCategories),
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

  group('CategoryPage widget tests', () {
    testWidgets(
      'renders CategoryAppBar, CategorySearchField, and all category cards',
      (tester) async {
        await tester.pumpWidget(createCategoryPageTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('All Categories'), findsOneWidget);
        expect(find.byType(CategorySearchField), findsOneWidget);
        expect(find.byType(CategoryCard), findsNWidgets(8));
        expect(find.text('Dentistry'), findsOneWidget);
        expect(find.text('Cardiology'), findsOneWidget);
        expect(find.text('Vaccination'), findsOneWidget);
      },
    );

    testWidgets('filters category cards dynamically when searching', (
      tester,
    ) async {
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

    testWidgets('shows CategoryEmptyState when search has no matches', (
      tester,
    ) async {
      await tester.pumpWidget(createCategoryPageTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'NonExistentSpecialty');
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCard), findsNothing);
      expect(find.byType(CategoryEmptyState), findsOneWidget);
      expect(find.text('No categories found'), findsOneWidget);
    });

    testWidgets(
      'invokes onCategoryTap callback when a category card is tapped',
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
      },
    );

    testWidgets('stacks every category vertically without using a GridView', (
      tester,
    ) async {
      await tester.pumpWidget(createCategoryPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsNothing);
      expect(find.byType(CategoryListView), findsOneWidget);

      final topOffsets = tester
          .widgetList<CategoryCard>(find.byType(CategoryCard))
          .map((card) => tester.getTopLeft(find.byWidget(card)).dy)
          .toList();

      expect(topOffsets.length, 8);
      for (var i = 1; i < topOffsets.length; i++) {
        expect(
          topOffsets[i],
          greaterThan(topOffsets[i - 1]),
          reason: 'card $i should sit below card ${i - 1}',
        );
      }
    });

    testWidgets('hides the edit button for non-admin users', (tester) async {
      await tester.pumpWidget(createCategoryPageTestWidget(isAdmin: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('category_edit_button')), findsNothing);
    });

    testWidgets('shows one edit button per category for admins', (
      tester,
    ) async {
      await tester.pumpWidget(createCategoryPageTestWidget(isAdmin: true));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('category_edit_button')), findsNWidgets(8));
    });

    testWidgets('tapping edit does not trigger the category card tap', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        createCategoryPageTestWidget(
          isAdmin: true,
          onCategoryTap: (_) => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('category_edit_button')).first);
      await tester.pumpAndSettle();

      expect(taps, 0);
    });

    testWidgets('flips the trailing arrow for RTL layouts', (tester) async {
      await tester.pumpWidget(createCategoryPageTestWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(8));

      await tester.pumpWidget(
        createCategoryPageTestWidget(textDirection: ui.TextDirection.rtl),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left_rounded), findsNWidgets(8));
    });

    testWidgets('keeps cards compact', (tester) async {
      await tester.pumpWidget(createCategoryPageTestWidget(isAdmin: true));
      await tester.pumpAndSettle();

      for (final card in tester.widgetList<CategoryCard>(
        find.byType(CategoryCard),
      )) {
        expect(tester.getSize(find.byWidget(card)).height, lessThan(80));
      }
    });

    testWidgets('uses a neutral white surface with no gradient or tint', (
      tester,
    ) async {
      await tester.pumpWidget(createCategoryPageTestWidget(isAdmin: true));
      await tester.pumpAndSettle();

      final decoration = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(CategoryCard).first,
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .first;

      expect(decoration.color, AppColors.white);
      expect(decoration.gradient, isNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('admin edit affordance is a bare icon with no filled circle', (
      tester,
    ) async {
      await tester.pumpWidget(createCategoryPageTestWidget(isAdmin: true));
      await tester.pumpAndSettle();

      final editButton = find.byKey(const Key('category_edit_button')).first;
      final icon = find.descendant(
        of: editButton,
        matching: find.byIcon(Icons.edit_rounded),
      );
      expect(icon, findsOneWidget);

      // No filled / circular container is rendered around the edit icon.
      expect(
        find.descendant(of: editButton, matching: find.byType(Container)),
        findsNothing,
      );
      expect(
        find.descendant(of: editButton, matching: find.byType(DecoratedBox)),
        findsNothing,
      );
    });
  });
}
