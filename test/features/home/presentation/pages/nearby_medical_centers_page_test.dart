import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/presentation/pages/nearby_medical_centers_page.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssetLoader extends AssetLoader {
  const _FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "nearbyMedicalCenters": "Nearby Medical Centers",
      "searchMedicalCenter": "Search medical center...",
      "contentNotFound": "Content not found",
      "seeAll": "See All",
      "reviews": "Reviews",
      "close": "Close",
      "category": "Category",
    };
  }
}

const List<MedicalCenterEntity> _testMedicalCenters = [
  MedicalCenterEntity(
    id: 'center_1',
    name: 'Sunrise Health Center',
    address: '123 Main St, New York',
    rating: 4.8,
    reviewsCount: 120,
    distance: 2.5,
    duration: 15,
    type: 'Hospital',
    imagePath: '',
  ),
  MedicalCenterEntity(
    id: 'center_2',
    name: 'Green Valley Clinic',
    address: '456 Oak Ave, Brooklyn',
    rating: 4.5,
    reviewsCount: 85,
    distance: 4.0,
    duration: 25,
    type: 'Clinic',
    imagePath: '',
  ),
  MedicalCenterEntity(
    id: 'center_3',
    name: 'Downtown Dental Care',
    address: '789 Broadway, Manhattan',
    rating: 4.9,
    reviewsCount: 200,
    distance: 1.2,
    duration: 8,
    type: 'Dental',
    imagePath: '',
  ),
];

Widget createNearbyMedicalCentersPageTestWidget({
  ValueChanged<MedicalCenterEntity>? onCenterTap,
  Stream<List<MedicalCenterEntity>>? medicalCentersStream,
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
            home: NearbyMedicalCentersPage(
              onCenterTap: onCenterTap,
              medicalCentersStream: medicalCentersStream ??
                  Stream.value(_testMedicalCenters),
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

  group('NearbyMedicalCentersPage widget tests', () {
    testWidgets('renders app bar title, search field, and all medical center items',
        (tester) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nearby Medical Centers'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(MedicalCenterItem), findsNWidgets(3));
      expect(find.text('Sunrise Health Center'), findsOneWidget);
      expect(find.text('Green Valley Clinic'), findsOneWidget);
      expect(find.text('Downtown Dental Care'), findsOneWidget);
    });

    testWidgets('filters medical centers dynamically when searching by name',
        (tester) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'valley');
      await tester.pumpAndSettle();

      expect(find.byType(MedicalCenterItem), findsOneWidget);
      expect(find.text('Green Valley Clinic'), findsOneWidget);
      expect(find.text('Sunrise Health Center'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(MedicalCenterItem), findsNWidgets(3));
    });

    testWidgets('shows empty state when search query matches nothing',
        (tester) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'UnknownCenterX');
      await tester.pumpAndSettle();

      expect(find.byType(MedicalCenterItem), findsNothing);
      expect(find.text('Content not found'), findsOneWidget);
    });

    testWidgets('invokes onCenterTap callback when a medical center item is tapped',
        (tester) async {
      MedicalCenterEntity? tappedCenter;
      await tester.pumpWidget(
        createNearbyMedicalCentersPageTestWidget(
          onCenterTap: (center) => tappedCenter = center,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sunrise Health Center'));
      await tester.pumpAndSettle();

      expect(tappedCenter?.name, 'Sunrise Health Center');
    });
  });
}
