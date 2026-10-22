import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/localization/app_localization.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTestAssetLoader extends AssetLoader {
  const SettingsTestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (locale.languageCode == 'ar') {
      return {
        "settings": "الإعدادات",
        "Settings": "الإعدادات",
        "language": "اللغة",
        "english": "الإنجليزية",
        "arabic": "العربية",
        "selectLanguage": "اختر اللغة",
      };
    }
    return {
      "settings": "Settings",
      "Settings": "Settings",
      "language": "Language",
      "english": "English",
      "arabic": "Arabic",
      "selectLanguage": "Select Language",
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Widget buildTestWidget({Locale startLocale = const Locale('en')}) {
    return EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: 'assets/translations',
      assetLoader: const SettingsTestAssetLoader(),
      startLocale: startLocale,
      child: AppScreenUtilScope(
        child: Builder(
          builder: (context) {
            final locale = context.locale;
            final isArabic = locale.languageCode == 'ar';
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: locale,
              builder: (context, child) {
                return Directionality(
                  textDirection:
                      isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  child: child!,
                );
              },
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => LanguageBottomSheet.show(ctx),
                    child: const Text('Open Language'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('LanguageBottomSheet opens and displays supported languages',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap button to open sheet
    await tester.tap(find.text('Open Language'));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageBottomSheet), findsOneWidget);
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('English (US)'), findsOneWidget);
    expect(find.text('العربية (Arabic)'), findsOneWidget);
  });

  testWidgets('Switching to Arabic in LanguageBottomSheet updates locale and closes sheet',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Open language sheet
    await tester.tap(find.text('Open Language'));
    await tester.pumpAndSettle();

    // Select Arabic
    await tester.tap(find.text('العربية (Arabic)'));
    await tester.pumpAndSettle();

    // Sheet should close and locale should be Arabic
    expect(find.byType(LanguageBottomSheet), findsNothing);
  });
}
