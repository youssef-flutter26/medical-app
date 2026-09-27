import 'package:flutter/widgets.dart';

abstract final class AppLocalization {
  const AppLocalization._();

  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  static const List<Locale> supportedLocales = [english, arabic];

  static const Locale fallbackLocale = english;
  static const Locale startLocale = english;

  static const String translationsPath = 'assets/translations';
}
