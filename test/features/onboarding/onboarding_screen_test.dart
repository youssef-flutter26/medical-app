import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "onboardingNext": "Next",
      "onboardingSkip": "Skip",
      "onboardingMeetDoctorsTitle": "Meet Doctors Online",
      "onboardingMeetDoctorsDescription":
          "Connect with Specialized Doctors Online for Convenient and Comprehensive Medical Consultations.",
      "onboardingConnectSpecialistsTitle": "Connect with Specialists",
      "onboardingSpecialistsTitle": "Thousands of Online Specialists",
      "onboardingSpecialistsDescription":
          "Explore a Vast Array of Online Medical Specialists, Offering an Extensive Range of Expertise Tailored to Your Healthcare Needs.",
    };
  }
}

Widget createOnboardingTestWidget({VoidCallback? onFinish}) {
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
            home: OnboardingScreen(onFinish: onFinish),
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

  testWidgets('OnboardingScreen displays Page 1 initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(createOnboardingTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Meet Doctors Online'), findsOneWidget);
    expect(
      find.text(
        'Connect with Specialized Doctors Online for Convenient and Comprehensive Medical Consultations.',
      ),
      findsOneWidget,
    );
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    final image = tester.widget<Image>(find.byType(Image).first);
    expect(image.image, const AssetImage(AppAssets.imagesOnboarding1));
  });

  testWidgets('Next button navigates through all 3 pages and to Auth',
      (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(createOnboardingTestWidget(onFinish: () {
      finished = true;
    }));
    await tester.pumpAndSettle();

    // Page 1
    expect(find.text('Meet Doctors Online'), findsOneWidget);

    // Tap Next -> Page 2
    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('Connect with Specialists'), findsOneWidget);
    final image2 = tester.widget<Image>(find.byType(Image).first);
    expect(image2.image, const AssetImage(AppAssets.imagesOnboarding2));

    // Tap Next -> Page 3
    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('Thousands of Online Specialists'), findsOneWidget);
    final image3 = tester.widget<Image>(find.byType(Image).first);
    expect(image3.image, const AssetImage(AppAssets.imagesOnboarding3));

    // Tap Next on Page 3 -> Auth entry
    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });

  testWidgets('Skip button from Page 1 navigates directly to Auth',
      (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(createOnboardingTestWidget(onFinish: () {
      finished = true;
    }));
    await tester.pumpAndSettle();

    expect(find.text('Meet Doctors Online'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_skip_button')));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });

  testWidgets('Skip button from Page 2 navigates to Auth',
      (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(createOnboardingTestWidget(onFinish: () {
      finished = true;
    }));
    await tester.pumpAndSettle();

    // Navigate to Page 2
    await tester.tap(find.byKey(const Key('onboarding_next_button')));
    await tester.pumpAndSettle();
    expect(find.text('Connect with Specialists'), findsOneWidget);

    // Tap Skip
    await tester.tap(find.byKey(const Key('onboarding_skip_button')));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });

  testWidgets('Horizontal drag swiping navigates between pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(createOnboardingTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Meet Doctors Online'), findsOneWidget);

    // Swipe left -> Page 2
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Connect with Specialists'), findsOneWidget);

    // Swipe left -> Page 3
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Thousands of Online Specialists'), findsOneWidget);

    // Swipe right -> Page 2
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Connect with Specialists'), findsOneWidget);
  });

  testWidgets('Skip button invokes onFinish callback',
      (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(createOnboardingTestWidget(onFinish: () {
      finished = true;
    }));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_skip_button')));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });
}
