import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SplashScreen displays AppAssets.imagesSplash with BoxFit.cover',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const AppScreenUtilScope(
        child: MaterialApp(
          home: SplashScreen(
            splashDuration: Duration(seconds: 10),
          ),
        ),
      ),
    );

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    final Image imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, const AssetImage(AppAssets.imagesSplash));
    expect(imageWidget.fit, BoxFit.cover);
    expect(imageWidget.alignment, Alignment.center);
  });

  testWidgets(
      'SplashScreen navigates to OnboardingScreen when not logged in and onboarding not seen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false, 'isOnboardingSeen': false});

    await tester.pumpWidget(
      AppScreenUtilScope(
        child: MaterialApp(
          home: const SplashScreen(
            splashDuration: Duration(milliseconds: 500),
          ),
          routes: {
            Routes.onboarding: (_) => const Scaffold(body: Text('OnboardingScreen')),
            Routes.login: (_) => const Scaffold(body: Text('LoginScreen')),
            Routes.mainLayout: (_) => const Scaffold(body: Text('MainLayout')),
          },
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('OnboardingScreen'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('OnboardingScreen'), findsOneWidget);
  });

  testWidgets(
      'SplashScreen navigates to LoginScreen when not logged in and onboarding seen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true, 'isOnboardingSeen': true});

    await tester.pumpWidget(
      AppScreenUtilScope(
        child: MaterialApp(
          home: const SplashScreen(
            splashDuration: Duration(milliseconds: 500),
          ),
          routes: {
            Routes.onboarding: (_) => const Scaffold(body: Text('OnboardingScreen')),
            Routes.login: (_) => const Scaffold(body: Text('LoginScreen')),
            Routes.mainLayout: (_) => const Scaffold(body: Text('MainLayout')),
          },
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('LoginScreen'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('LoginScreen'), findsOneWidget);
  });
}
