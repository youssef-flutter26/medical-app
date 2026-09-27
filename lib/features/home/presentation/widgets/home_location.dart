import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class HomeLocation extends StatelessWidget {
  const HomeLocation({
    super.key,
    this.location = 'Seattle, USA',
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
                'Location',
                style: AppTextStyles.withColor(
                  AppTextStyles.inter12W500,
                  AppColors.gray500,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16.r,
                    color: AppColors.primary600,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    location,
                    style: AppTextStyles.withColor(
                      AppTextStyles.inter14W500,
                      AppColors.darkTeal,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18.r,
                    color: AppColors.gray500,
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
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 22.r,
                  color: AppColors.gray700,
                ),
                if (hasNotification)
                  Positioned(
                    top: 10.h,
                    right: 11.w,
                    child: Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: Colors.red,
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
