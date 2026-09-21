import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:medical_app/features/splash/presentation/views/splash_screen.dart';

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

  testWidgets('SplashScreen navigates to OnboardingScreen after duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const AppScreenUtilScope(
        child: MaterialApp(
          home: SplashScreen(
            splashDuration: Duration(milliseconds: 500),
          ),
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
