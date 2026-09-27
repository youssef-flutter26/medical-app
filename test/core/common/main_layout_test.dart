import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/common/main_layout.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/appointment/presentation/screens/appointment_screen.dart';
import 'package:medical_app/features/home/presentation/screens/home_screen.dart';
import 'package:medical_app/features/location/presentation/screens/location_screen.dart';
import 'package:medical_app/features/profile/presentation/screens/profile_screen.dart';
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
    };
  }
}

Widget createMainLayoutTestWidget() {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const TestAssetLoader(),
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: Builder(
      builder: (context) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const MainLayout(),
        );
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('MainLayout renders with 4 tabs and switches screens on tap', (
    tester,
  ) async {
    await tester.pumpWidget(createMainLayoutTestWidget());
    await tester.pumpAndSettle();

    // Initial tab should be Home
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(HomeScreen), matching: find.text('Home')),
      findsOneWidget,
    );
    expect(find.byType(LocationScreen), findsNothing);
    expect(find.byType(AppointmentScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsNothing);

    // Check BottomNavigationBar items
    final bottomNavBarFinder = find.byType(BottomNavigationBar);
    expect(bottomNavBarFinder, findsOneWidget);

    final BottomNavigationBar bottomNavBar = tester.widget(bottomNavBarFinder);
    expect(bottomNavBar.items.length, 4);
    expect(bottomNavBar.items[0].label, 'Home');
    expect(bottomNavBar.items[1].label, 'Location');
    expect(bottomNavBar.items[2].label, 'Appointment');
    expect(bottomNavBar.items[3].label, 'Profile');

    // Tap Location (second item)
    await tester.tap(find.byType(InkResponse).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(LocationScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LocationScreen),
        matching: find.text('Location'),
      ),
      findsOneWidget,
    );
    expect(find.byType(HomeScreen), findsNothing);

    // Tap Appointment (third item)
    await tester.tap(find.byType(InkResponse).at(2));
    await tester.pumpAndSettle();

    expect(find.byType(AppointmentScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppointmentScreen),
        matching: find.text('Appointment'),
      ),
      findsOneWidget,
    );

    // Tap Profile (fourth item)
    await tester.tap(find.byType(InkResponse).at(3));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ProfileScreen),
        matching: find.text('Profile'),
      ),
      findsOneWidget,
    );

    // Tap Home (first item)
    await tester.tap(find.byType(InkResponse).at(0));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(HomeScreen), matching: find.text('Home')),
      findsOneWidget,
    );
  });

  testWidgets('MainLayout uses AppColors.gray600 for selected icon', (
    tester,
  ) async {
    await tester.pumpWidget(createMainLayoutTestWidget());
    await tester.pumpAndSettle();

    final BottomNavigationBar bottomNavBar = tester.widget(
      find.byType(BottomNavigationBar),
    );

    expect(bottomNavBar.selectedItemColor, AppColors.gray600);
    expect(bottomNavBar.selectedIconTheme?.color, AppColors.gray600);
    expect(bottomNavBar.unselectedItemColor, AppColors.gray400);
    expect(bottomNavBar.unselectedIconTheme?.color, AppColors.gray400);
    expect(AppColors.gray600, const Color(0xFF4B5563));

    // Check that all active icons use gray600 colorFilter and unselected use gray400
    for (int i = 0; i < bottomNavBar.items.length; i++) {
      final activeSvg = bottomNavBar.items[i].activeIcon as SvgPicture;
      expect(
        activeSvg.colorFilter,
        const ColorFilter.mode(AppColors.gray600, BlendMode.srcIn),
      );

      final unselectedSvg = bottomNavBar.items[i].icon as SvgPicture;
      expect(
        unselectedSvg.colorFilter,
        const ColorFilter.mode(AppColors.gray400, BlendMode.srcIn),
      );
    }
  });
}
