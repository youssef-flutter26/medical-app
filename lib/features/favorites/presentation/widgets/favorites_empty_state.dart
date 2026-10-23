import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class FavoritesEmptyState extends StatelessWidget {
  final bool isDoctor;

  const FavoritesEmptyState({
    super.key,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final title = isDoctor
        ? LocaleKeys.noFavoriteDoctors.tr()
        : LocaleKeys.noFavoriteHospitals.tr();
    final description = LocaleKeys.noFavoritesDescription.tr();

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.darkTeal.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isDoctor
                      ? Icons.favorite_border_rounded
                      : Icons.local_hospital_outlined,
                  size: 46.r,
                  color: AppColors.darkTeal.withValues(alpha: 0.35),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: AppTextStyles.inter16W500.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: AppTextStyles.inter12W400.copyWith(
                fontSize: 13.sp,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
