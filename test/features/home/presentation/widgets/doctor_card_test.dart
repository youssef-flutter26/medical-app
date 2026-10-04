import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/home/presentation/widgets/doctor_card.dart';

class _FakeDoctorCardAssetLoader extends AssetLoader {
  const _FakeDoctorCardAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "reviews": "Reviews",
    };
  }
}

Widget _wrapWithApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeDoctorCardAssetLoader(),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(body: child),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DoctorCard rating formatting', () {
    testWidgets('displays decimal ratings (4.1, 4.5, 4.7, 4.8, 4.9) and integer ratings correctly',
        (tester) async {
      const testRatings = [
        (4.1, '4.1'),
        (4.5, '4.5'),
        (4.7, '4.7'),
        (4.8, '4.8'),
        (4.9, '4.9'),
        (5.0, '5'),
      ];

      for (final item in testRatings) {
        final ratingVal = item.$1;
        final expectedText = item.$2;
        final doctor = DoctorData(
          name: 'Dr. Test',
          specialty: 'Cardiologist',
          location: 'Test Hospital',
          rating: ratingVal,
          reviewCount: 100,
        );

        await tester.pumpWidget(_wrapWithApp(DoctorCard(doctor: doctor)));
        await tester.pumpAndSettle();

        expect(find.text(expectedText), findsOneWidget,
            reason: 'Rating $ratingVal should be formatted as $expectedText');
      }
    });

    testWidgets('shows edit icon only when isAdmin is true and triggers onEdit',
        (tester) async {
      bool editTapped = false;
      final doctor = DoctorData(
        id: 'doc1',
        name: 'Dr. John Doe',
        specialty: 'Cardiologist',
        location: 'Heart Hospital',
        rating: 4.8,
        reviewCount: 200,
      );

      // When isAdmin is false, edit icon is hidden
      await tester.pumpWidget(_wrapWithApp(
        DoctorCard(
          doctor: doctor,
          isAdmin: false,
          onEdit: () => editTapped = true,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('doctor_edit_button')), findsNothing);

      // When isAdmin is true, edit icon is visible and triggers onEdit
      await tester.pumpWidget(_wrapWithApp(
        DoctorCard(
          doctor: doctor,
          isAdmin: true,
          onEdit: () => editTapped = true,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('doctor_edit_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('doctor_edit_button')));
      await tester.pumpAndSettle();
      expect(editTapped, isTrue);
    });
  });
}
