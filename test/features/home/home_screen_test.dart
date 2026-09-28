import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/home/presentation/pages/home_screen.dart';
import 'package:medical_app/features/home/presentation/widgets/category_item.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
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
    };
  }
}

Widget createHomeScreenTestWidget() {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const HomeTestAssetLoader(),
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: const AppScreenUtilScope(
      child: Builder(
        builder: _buildMaterialApp,
      ),
    ),
  );
}

Widget _buildMaterialApp(BuildContext context) {
  return MaterialApp(
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    home: const HomeScreen(),
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
    await tester.pumpWidget(createHomeScreenTestWidget());
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
    expect(find.text('Dentistry'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('Pulmonology'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Neurology'), findsOneWidget);
    expect(find.text('Gastro...'), findsOneWidget);
    expect(find.text('Laboratory'), findsOneWidget);
    expect(find.text('Vaccination'), findsOneWidget);

    // 5. Nearby Medical Centers section
    expect(find.byType(NearbyMedicalCenters), findsOneWidget);
    expect(find.text('Nearby Medical Centers'), findsOneWidget);
    expect(find.byType(MedicalCenterItem), findsNWidgets(2));
    expect(find.text('Sunrise Health Clinic'), findsOneWidget);
    expect(find.text('Golden Cardio...'), findsOneWidget);
  });

  testWidgets('HomeBanner displays banner image using Image.asset', (
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

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, isA<AssetImage>());
    expect((imageWidget.image as AssetImage).assetName, 'assets/images/banner1.png');
  });
}

