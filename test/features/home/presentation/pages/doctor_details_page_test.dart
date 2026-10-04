import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/presentation/pages/doctor_details_page.dart';

class _FakeDoctorDetailsAssetLoader extends AssetLoader {
  const _FakeDoctorDetailsAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "doctorDetails": "Doctor Details",
      "aboutDoctor": "About Doctor",
      "experience": "Experience",
      "reviews": "Reviews",
      "appointment": "Appointment",
    };
  }
}

Widget createDoctorDetailsTestWidget(
  DoctorEntity doctor, {
  bool? isAdmin,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeDoctorDetailsAssetLoader(),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: DoctorDetailsPage(
              doctor: doctor,
              isAdmin: isAdmin,
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DoctorDetailsPage', () {
    const testDoctor = DoctorEntity(
      id: 'doc1',
      name: 'Dr. David Patel',
      specialty: 'Cardiologist',
      categoryId: 'cat_cardiology',
      categoryName: 'Cardiology',
      address: 'Cardiology Center, USA',
      rating: 4.9,
      reviewsCount: 1872,
      availableTime: 'Mon - Fri: 08:00 AM - 04:00 PM',
      imagePath: '',
    );

    testWidgets('renders all doctor details correctly', (tester) async {
      await tester.pumpWidget(createDoctorDetailsTestWidget(testDoctor));
      await tester.pumpAndSettle();

      // 1. Header & Title
      expect(find.text('Doctor Details'), findsOneWidget);

      // 2. Doctor Info
      expect(find.text('Dr. David Patel'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('Cardiology Center, USA'), findsOneWidget);

      // 3. Stats (Rating and Reviews rendered; Experience removed)
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('1,872'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('10+ yrs'), findsNothing);
      expect(find.text('Experience'), findsNothing);

      // 4. About Doctor section (removed)
      expect(find.text('About Doctor'), findsNothing);
      expect(
        find.text(
          'Passionate and board-certified cardiologist with extensive clinical experience.',
        ),
        findsNothing,
      );

      // 5. Working Hours & Available Time
      expect(find.text('Working Hours'), findsOneWidget);
      expect(find.text('Mon - Fri: 08:00 AM - 04:00 PM'), findsOneWidget);

      // 6. Action Button
      expect(find.text('Appointment'), findsOneWidget);
    });

    testWidgets('renders gradient profile card with soft elegant shadow',
        (tester) async {
      await tester.pumpWidget(createDoctorDetailsTestWidget(testDoctor));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).gradient != null,
      );

      final decoration = gradientContainer.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
      expect(decoration.boxShadow!.first.blurRadius, greaterThan(0));
    });

    testWidgets('hides edit button when isAdmin is false', (tester) async {
      await tester.pumpWidget(
        createDoctorDetailsTestWidget(testDoctor, isAdmin: false),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('doctor_details_edit_button')), findsNothing);
      expect(find.byKey(const Key('doctor_card_edit_button')), findsNothing);
    });

    testWidgets('shows edit button when isAdmin is true', (tester) async {
      await tester.pumpWidget(
        createDoctorDetailsTestWidget(testDoctor, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('doctor_details_edit_button')), findsOneWidget);
      expect(find.byKey(const Key('doctor_card_edit_button')), findsOneWidget);
    });
  });
}
