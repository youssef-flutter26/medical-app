import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/app_localization.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/routing/app_router.dart';
import 'package:medical_app/core/theme/app_theme.dart';
import 'package:medical_app/features/splash/presentation/views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: AppLocalization.translationsPath,
      fallbackLocale: AppLocalization.fallbackLocale,
      child: AppScreenUtilScope(
        child: Builder(
          builder: (context) {
            final locale = context.locale;
            const textDirection = ui.TextDirection.ltr;

            return MaterialApp(
              key: ValueKey(locale.languageCode),
              title: LocaleKeys.appName.tr(),
              theme: AppTheme.theme,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: locale,
              builder: (context, child) {
                return Directionality(
                  textDirection: textDirection,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              onGenerateRoute: getIt<AppRouter>().generateRoute,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
