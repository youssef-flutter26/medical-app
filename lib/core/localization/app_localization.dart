import 'package:flutter/widgets.dart';

abstract final class AppLocalization {
  const AppLocalization._();

  static const List<Locale> supportedLocales = [
    Locale('en'),
  ];

  static const Locale fallbackLocale = Locale('en');

  static const String translationsPath = 'assets/translations';
}