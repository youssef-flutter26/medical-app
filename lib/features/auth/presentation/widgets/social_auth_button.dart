import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class SocialAuthButtons extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback? onPressed;

  const SocialAuthButtons({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 41.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.gray700,
          padding: EdgeInsets.zero,
          side: BorderSide(color: AppColors.gray400.withOpacity(0.45)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 15.w, height: 15.h),
            SizedBox(width: 6.w),
            Text(
              text,
              style: AppTextStyles.withColor(
                AppTextStyles.inter10W500,
                AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
