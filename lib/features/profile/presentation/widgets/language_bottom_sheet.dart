import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/app_localization.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguageBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        22.h,
        24.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.selectLanguage.tr(),
            style: AppTextStyles.inter18W700.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTeal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.gray100,
          ),
          SizedBox(height: 12.h),
          _buildLanguageOption(
            context: context,
            title: LocaleKeys.english.tr(),
            nativeName: 'English (US)',
            locale: AppLocalization.english,
            isSelected: currentLocale.languageCode == 'en',
          ),
          SizedBox(height: 8.h),
          _buildLanguageOption(
            context: context,
            title: LocaleKeys.arabic.tr(),
            nativeName: 'العربية (Arabic)',
            locale: AppLocalization.arabic,
            isSelected: currentLocale.languageCode == 'ar',
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String nativeName,
    required Locale locale,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        if (!isSelected) {
          await context.setLocale(locale);
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkTeal.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.darkTeal : AppColors.gray100,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.darkTeal
                    : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  locale.languageCode.toUpperCase(),
                  style: AppTextStyles.inter12W500.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.gray600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.inter16W500.copyWith(
                      fontSize: 15.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.darkTeal
                          : AppColors.gray700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    nativeName,
                    style: AppTextStyles.inter12W400.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.darkTeal,
                size: 22.r,
              )
            else
              Icon(
                Icons.radio_button_unchecked_rounded,
                color: AppColors.gray400,
                size: 22.r,
              ),
          ],
        ),
      ),
    );
  }
}
