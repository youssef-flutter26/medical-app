import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.darkTeal,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.gray700,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.gray700),
        titleTextStyle: AppTextStyles.inter18W700,
      ),
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.inter18W700,
        bodyLarge: AppTextStyles.inter16W500,
        bodyMedium: AppTextStyles.inter14W400,
      ),
    );
  }
}
