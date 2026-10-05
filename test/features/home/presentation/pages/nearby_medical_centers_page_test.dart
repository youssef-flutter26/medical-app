import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/theme/app_colors.dart';
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

const List<MedicalCenterEntity> _testMedicalCentersWithoutType = [
  MedicalCenterEntity(
    id: 'center_9',
    name: 'Riverside Imaging',
    address: '10 River Rd, Queens',
    rating: 4.1,
    reviewsCount: 12,
    distance: 0.8,
    duration: 5,
    type: '',
    imagePath: '',
  ),
];

Widget createNearbyMedicalCentersPageTestWidget({
  ValueChanged<MedicalCenterEntity>? onCenterTap,
  ValueChanged<MedicalCenterEntity>? onEditCenter,
  Stream<List<MedicalCenterEntity>>? medicalCentersStream,
  bool? isAdmin = false,
  TextDirection? textDirection,
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
            builder: textDirection == null
                ? null
                : (context, child) => Directionality(
                    textDirection: textDirection,
                    child: child!,
                  ),
            home: NearbyMedicalCentersPage(
              isAdmin: isAdmin,
              onCenterTap: onCenterTap,
              onEditCenter: onEditCenter,
              medicalCentersStream:
                  medicalCentersStream ?? Stream.value(_testMedicalCenters),
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
    testWidgets(
      'renders app bar title, search field, and all medical center items',
      (tester) async {
        await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Nearby Medical Centers'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(MedicalCenterItem), findsNWidgets(3));
        expect(find.text('Sunrise Health Center'), findsOneWidget);
        expect(find.text('Green Valley Clinic'), findsOneWidget);
        expect(find.text('Downtown Dental Care'), findsOneWidget);
      },
    );

    testWidgets('filters medical centers dynamically when searching by name', (
      tester,
    ) async {
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

    testWidgets('shows empty state when search query matches nothing', (
      tester,
    ) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'UnknownCenterX');
      await tester.pumpAndSettle();

      expect(find.byType(MedicalCenterItem), findsNothing);
      expect(find.text('Content not found'), findsOneWidget);
    });

    testWidgets(
      'invokes onCenterTap callback when a medical center item is tapped',
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
      },
    );

    testWidgets(
      'lays the image beside the details in a compact horizontal card',
      (tester) async {
        // Render at the app design size so the proportions match a real device.
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
        await tester.pumpAndSettle();

        final thumbnail = find
            .byKey(const Key('medical_center_thumbnail'))
            .first;
        final details = find.byKey(const Key('medical_center_details')).first;

        final cardSize = tester.getSize(find.byType(MedicalCenterItem).first);
        final imageSize = tester.getSize(thumbnail);
        final imageTopLeft = tester.getTopLeft(thumbnail);
        final detailsTopLeft = tester.getTopLeft(details);
        final detailsSize = tester.getSize(details);

        // Image on one side, details on the other side of the same row.
        expect(imageTopLeft.dx, lessThan(detailsTopLeft.dx));

        // They sit side by side, not stacked on top of each other.
        expect(
          imageTopLeft.dy,
          lessThan(detailsTopLeft.dy + detailsSize.height),
        );
        expect(detailsTopLeft.dy, lessThan(imageTopLeft.dy + imageSize.height));

        // Image is a noticeable portion of the card, but not the whole card:
        // it takes roughly 35-40% of the card width.
        expect(imageSize.width / cardSize.width, inInclusiveRange(0.33, 0.43));
        expect(imageSize.width, lessThan(cardSize.width * 0.5));

        // Fixed and proportional: no distortion from varying image sizes.
        expect(imageSize.width, closeTo(imageSize.height, 1));

        // Compact height: still clearly wider than tall.
        expect(cardSize.height, lessThan(cardSize.width * 0.5));
      },
    );

    testWidgets('renders a plain white card with no gradients', (tester) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(LinearGradient), findsNothing);
      expect(find.byType(RadialGradient), findsNothing);

      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MedicalCenterItem).first,
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = card.decoration! as BoxDecoration;

      expect(decoration.color, AppColors.white);
      expect(decoration.gradient, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(12.r));
    });

    testWidgets('shows the existing center details on the details side', (
      tester,
    ) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sunrise Health Center'), findsOneWidget);
      expect(find.text('123 Main St, New York'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(120 Reviews)'), findsOneWidget);
      expect(find.text('2.5 km / 15 min'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
    });

    testWidgets('omits the type line when the stored type is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        createNearbyMedicalCentersPageTestWidget(
          medicalCentersStream: Stream.value(_testMedicalCentersWithoutType),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Riverside Imaging'), findsOneWidget);
      expect(find.text('10 River Rd, Queens'), findsOneWidget);
      expect(find.text('0.8 km / 5 min'), findsOneWidget);

      // No fabricated fallback label.
      expect(find.text('Hospital'), findsNothing);
      expect(find.text('Clinic'), findsNothing);
    });

    testWidgets('hides the edit icon from non-admin users', (tester) async {
      await tester.pumpWidget(createNearbyMedicalCentersPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('medical_center_edit_button')), findsNothing);
    });

    testWidgets('places a small edit icon in the details header for admins', (
      tester,
    ) async {
      await tester.pumpWidget(
        createNearbyMedicalCentersPageTestWidget(isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('medical_center_edit_button')),
        findsNWidgets(3),
      );

      final editRect = tester.getRect(
        find.byKey(const Key('medical_center_edit_button')).first,
      );
      final imageRect = tester.getRect(
        find.byKey(const Key('medical_center_thumbnail')).first,
      );
      final detailsRect = tester.getRect(
        find.byKey(const Key('medical_center_details')).first,
      );
      final nameRect = tester.getRect(find.text('Sunrise Health Center'));

      // Inside the details section, not overlaid on the image.
      expect(editRect.left, greaterThan(imageRect.right));
      expect(editRect.right, lessThanOrEqualTo(detailsRect.right + 1));

      // Top aligned with the name row, on the end side in LTR.
      expect((editRect.center.dy - nameRect.center.dy).abs(), lessThan(8));
      expect(
        editRect.top - detailsRect.top,
        lessThan(detailsRect.height * 0.4),
      );
      expect(editRect.left, greaterThan(nameRect.left));

      // Small and clean, not a large coloured button.
      expect(editRect.width, lessThanOrEqualTo(30));
      expect(editRect.height, lessThanOrEqualTo(30));
    });

    testWidgets('uses the app standard small edit icon style', (tester) async {
      await tester.pumpWidget(
        createNearbyMedicalCentersPageTestWidget(isAdmin: true),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find
            .descendant(
              of: find.byKey(const Key('medical_center_edit_button')).first,
              matching: find.byIcon(Icons.edit_rounded),
            )
            .first,
      );

      expect(icon.size, 14.r);
      expect(icon.color, AppColors.darkTeal);
    });

    testWidgets(
      'tapping edit opens the existing edit flow without the card tap',
      (tester) async {
        MedicalCenterEntity? editedCenter;
        MedicalCenterEntity? tappedCenter;

        await tester.pumpWidget(
          createNearbyMedicalCentersPageTestWidget(
            isAdmin: true,
            onCenterTap: (center) => tappedCenter = center,
            onEditCenter: (center) => editedCenter = center,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('medical_center_edit_button')).first,
        );
        await tester.pumpAndSettle();

        expect(editedCenter?.name, 'Sunrise Health Center');
        expect(tappedCenter, isNull);
      },
    );

    testWidgets('mirrors the card and the edit icon for RTL', (tester) async {
      await tester.pumpWidget(
        createNearbyMedicalCentersPageTestWidget(
          isAdmin: true,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      final details = find.byKey(const Key('medical_center_details')).first;
      final imageTopLeft = tester.getTopLeft(
        find.byKey(const Key('medical_center_thumbnail')).first,
      );
      final detailsTopLeft = tester.getTopLeft(details);

      // Image moves to the end side.
      expect(imageTopLeft.dx, greaterThan(detailsTopLeft.dx));

      final detailsRect = tester.getRect(details);
      final nameRect = tester.getRect(find.text('Sunrise Health Center'));
      final editRect = tester.getRect(
        find.byKey(const Key('medical_center_edit_button')).first,
      );

      // Edit icon follows the name to the start side.
      expect(editRect.left, lessThan(nameRect.left));
      expect(
        editRect.top - detailsRect.top,
        lessThan(detailsRect.height * 0.4),
      );
    });
  });
}
