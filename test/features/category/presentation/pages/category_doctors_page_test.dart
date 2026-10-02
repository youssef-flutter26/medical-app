import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/category/presentation/pages/category_doctors_page.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/category_doctors_header.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/category_doctors_list.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/doctor_card.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

class _FakeCategoryDoctorsAssetLoader extends AssetLoader {
  const _FakeCategoryDoctorsAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "allDoctors": "All Doctors",
      "searchDoctor": "Search doctor...",
      "founds": "founds",
      "defaultSort": "Default",
      "reviews": "Reviews",
      "noDoctorsFound": "No doctors found",
    };
  }
}

Widget createCategoryDoctorsTestWidget({
  String? categoryName,
  CategoryEntity? category,
  String? pageTitle,
  List<DoctorData>? initialDoctors,
  int? resultsCount,
  NavigatorObserver? navigatorObserver,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeCategoryDoctorsAssetLoader(),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            navigatorObservers: [
              ?navigatorObserver,
            ],
            home: CategoryDoctorsPage(
              categoryName: categoryName,
              category: category,
              pageTitle: pageTitle,
              initialDoctors: initialDoctors,
              resultsCount: resultsCount,
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'CategoryDoctorsPage renders AppBar, search, count, sort and reference doctors',
      (WidgetTester tester) async {
    await tester.pumpWidget(createCategoryDoctorsTestWidget());
    await tester.pumpAndSettle();

    // 1. AppBar
    expect(find.text('All Doctors'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // 2. Header: Search, count and sort
    expect(find.byType(CategoryDoctorsHeader), findsOneWidget);
    expect(find.text('Search doctor...'), findsOneWidget);
    expect(find.text('532 founds'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);

    // 3. Doctor cards from reference image
    expect(find.byType(CategoryDoctorsList), findsOneWidget);
    expect(find.text('Dr. David Patel'), findsOneWidget);
    expect(find.text('Cardiologist'), findsOneWidget);
    expect(find.text('Cardiology Center, USA'), findsOneWidget);
    expect(find.text('5'), findsWidgets);
    expect(find.text('1,872 Reviews'), findsOneWidget);

    expect(find.text('Dr. Jessica Turner'), findsOneWidget);
    expect(find.text('Gynecologist'), findsOneWidget);
    expect(find.text("Women's Clinic,Seattle,USA"), findsOneWidget);
    expect(find.text('4.9'), findsWidgets);
    expect(find.text('127 Reviews'), findsOneWidget);

    expect(find.text('Dr. Michael Johnson'), findsOneWidget);
    expect(find.text('Orthopedic Surgery'), findsOneWidget);
    expect(find.text('Maple Associates, NY,USA'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('5,223 Reviews'), findsOneWidget);

    expect(find.text('Dr. Emily Walker'), findsWidgets);
    expect(find.text('Pediatrics'), findsWidgets);
  });

  testWidgets(
      'CategoryDoctorsPage filters doctors by selected Category from Home',
      (WidgetTester tester) async {
    await tester.pumpWidget(createCategoryDoctorsTestWidget(
      categoryName: 'Cardiology',
    ));
    await tester.pumpAndSettle();

    // Only Cardiology doctors should be shown
    expect(find.text('Dr. David Patel'), findsOneWidget);
    expect(find.text('Cardiologist'), findsOneWidget);

    // Other specialty doctors should not be shown
    expect(find.text('Dr. Jessica Turner'), findsNothing);
    expect(find.text('Dr. Michael Johnson'), findsNothing);

    // Results count updates to filtered count
    expect(find.text('1 founds'), findsOneWidget);
  });

  testWidgets(
      'CategoryDoctorsPage displays empty state when category has no doctors',
      (WidgetTester tester) async {
    await tester.pumpWidget(createCategoryDoctorsTestWidget(
      categoryName: 'Vaccination',
    ));
    await tester.pumpAndSettle();

    expect(find.text('No doctors found'), findsOneWidget);
    expect(find.text('0 founds'), findsOneWidget);
    expect(find.byType(DoctorCard), findsNothing);
  });

  testWidgets(
      'CategoryDoctorsPage filters doctors dynamically by search query',
      (WidgetTester tester) async {
    await tester.pumpWidget(createCategoryDoctorsTestWidget());
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Jessica');
    await tester.pumpAndSettle();

    expect(find.text('Dr. Jessica Turner'), findsOneWidget);
    expect(find.text('Dr. David Patel'), findsNothing);
    expect(find.text('1 founds'), findsOneWidget);

    // Clear search
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Dr. David Patel'), findsOneWidget);
    expect(find.text('532 founds'), findsOneWidget);
  });

  testWidgets(
      'DoctorCard toggles favorite state on heart icon tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(createCategoryDoctorsTestWidget());
    await tester.pumpAndSettle();

    final favoriteButton = find.byIcon(Icons.favorite_border_rounded).first;
    expect(favoriteButton, findsOneWidget);

    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });
}
