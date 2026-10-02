import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/presentation/pages/doctor_details_page.dart';

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

Widget createDoctorDetailsTestWidget(DoctorEntity doctor) {
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
            home: DoctorDetailsPage(doctor: doctor),
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
      experience: 10,
      rating: 4.9,
      reviewsCount: 1872,
      about: 'Passionate and board-certified cardiologist with extensive clinical experience.',
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

      // 3. Stats (Rating, Reviews, Experience)
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('1,872'), findsOneWidget);
      expect(find.text('10+ yrs'), findsOneWidget);

      // 4. About Doctor section
      expect(find.text('About Doctor'), findsOneWidget);
      expect(
        find.text(
          'Passionate and board-certified cardiologist with extensive clinical experience.',
        ),
        findsOneWidget,
      );

      // 5. Working Hours & Available Time
      expect(find.text('Working Hours'), findsOneWidget);
      expect(find.text('Mon - Fri: 08:00 AM - 04:00 PM'), findsOneWidget);

      // 6. Action Button
      expect(find.text('Appointment'), findsOneWidget);
    });
  });
}
