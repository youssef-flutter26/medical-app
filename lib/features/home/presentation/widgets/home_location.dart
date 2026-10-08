import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class HomeLocation extends StatelessWidget {
  const HomeLocation({
    super.key,
    this.location = 'Current Location',
    this.hasNotification = true,
    this.onNotificationPressed,
    this.onLocationPressed,
  });

  final String location;
  final bool hasNotification;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onLocationPressed,
          borderRadius: BorderRadius.circular(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.location.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter12W500,
                  AppColors.gray500,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.iconsLocation2,
                    width: 17.r,
                    height: 21.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    location,
                    style: AppTextStyles.withColor(
                      AppTextStyles.inter14W500.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      AppColors.darkTeal,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    AppAssets.iconsArrowDown,
                    width: 14.r,
                    height: 14.r,
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onNotificationPressed,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.iconsNotificationBing,
                  width: 22.r,
                  height: 22.r,
                ),
                if (hasNotification)
                  Positioned(
                    top: 9.r,
                    right: 10.r,
                    child: Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}