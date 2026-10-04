import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/common/pages/main_layout.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/home/presentation/pages/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "home": "Home",
      "location": "Location",
      "appointment": "Appointment",
      "profile": "Profile",
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
      "user": "User",
      "logOut": "Log out",
      "cancel": "Cancel",
    };
  }
}

Widget createMainLayoutTestWidget({List<Widget>? screens}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const TestAssetLoader(),
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: AppScreenUtilScope(
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: MainLayout(screens: screens),
          );
        },
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('MainLayout renders with 3 tabs and switches screens on tap', (
    tester,
  ) async {
    await tester.pumpWidget(createMainLayoutTestWidget(
      screens: const [
        HomeScreen(),
        Center(child: Text('Location')),
        Center(child: Text('Appointment')),
      ],
    ));
    await tester.pumpAndSettle();

    // Initial tab should be Home
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Center), matching: find.text('Location')),
      findsNothing,
    );
    expect(
      find.descendant(of: find.byType(Center), matching: find.text('Appointment')),
      findsNothing,
    );

    // Check BottomNavigationBar items
    final bottomNavBarFinder = find.byType(BottomNavigationBar);
    expect(bottomNavBarFinder, findsOneWidget);

    final BottomNavigationBar bottomNavBar = tester.widget(bottomNavBarFinder);
    expect(bottomNavBar.items.length, 3);
    expect(bottomNavBar.items[0].label, 'Home');
    expect(bottomNavBar.items[1].label, 'Location');
    expect(bottomNavBar.items[2].label, 'Appointment');

    // Tap Location (second item)
    await tester.tap(find.byType(InkResponse).at(1));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(Center), matching: find.text('Location')),
      findsOneWidget,
    );
    expect(find.byType(HomeScreen), findsNothing);

    // Tap Appointment (third item)
    await tester.tap(find.byType(InkResponse).at(2));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(Center), matching: find.text('Appointment')),
      findsOneWidget,
    );

    // Tap Home (first item)
    await tester.tap(find.byType(InkResponse).at(0));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('MainLayout uses 48px gray100 circle and -2 assets for selected icon', (
    tester,
  ) async {
    await tester.pumpWidget(createMainLayoutTestWidget());
    await tester.pumpAndSettle();

    final BottomNavigationBar bottomNavBar = tester.widget(
      find.byType(BottomNavigationBar),
    );

    expect(bottomNavBar.selectedItemColor, AppColors.gray600);
    expect(bottomNavBar.unselectedItemColor, AppColors.gray400);
    expect(AppColors.gray100, const Color(0xFFF3F4F6));

    final expectedActiveAssets = [
      AppAssets.iconsHome2,
      AppAssets.iconsLocation2,
      AppAssets.iconsCalendar2,
    ];

    for (int i = 0; i < bottomNavBar.items.length; i++) {
      final activeContainer = bottomNavBar.items[i].activeIcon as Container;
      expect(activeContainer.constraints?.minWidth, 48.0);
      expect(activeContainer.constraints?.minHeight, 48.0);

      final decoration = activeContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, AppColors.gray100);
      expect(decoration.border, isNull);

      final activeSvg = activeContainer.child as SvgPicture;
      expect(activeSvg.colorFilter, isNull);
      final assetBytesLoader = activeSvg.bytesLoader as SvgAssetLoader;
      expect(assetBytesLoader.assetName, expectedActiveAssets[i]);

      final unselectedSvg = bottomNavBar.items[i].icon as SvgPicture;
      expect(
        unselectedSvg.colorFilter,
        const ColorFilter.mode(AppColors.gray400, BlendMode.srcIn),
      );
    }
  });
}
