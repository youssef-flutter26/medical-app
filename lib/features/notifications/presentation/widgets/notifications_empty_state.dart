import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                color: AppColors.darkTeal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.iconsNotificationBing,
                  width: 44.r,
                  height: 44.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.darkTeal,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              LocaleKeys.noNotificationsYet.tr(),
              style: AppTextStyles.inter18W700.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              LocaleKeys.noNotificationsDescription.tr(),
              style: AppTextStyles.inter14W400.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsErrorState extends StatelessWidget {
  const NotificationsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.r,
              height: 90.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  color: const Color(0xFFDC2626),
                  size: 44.r,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Failed to Load Notifications',
              style: AppTextStyles.inter18W700.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              message.isNotEmpty
                  ? message
                  : 'An error occurred while loading your notifications.',
              style: AppTextStyles.inter14W400.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 140.w,
              height: 44.h,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 20),
                label: Text(
                  'Try Again',
                  style: AppTextStyles.inter14W500.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
