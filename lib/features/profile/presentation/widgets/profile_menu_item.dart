import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class ProfileMenuItem extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final VoidCallback onTap;
  final bool showChevron;
  final Color? titleColor;

  const ProfileMenuItem({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
    this.showChevron = true,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = titleColor ?? AppColors.gray700;

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.gray100,
      highlightColor: AppColors.gray100.withValues(alpha: 0.5),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
        child: Row(
          children: [
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: Center(child: leadingIcon),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.inter16W500.copyWith(
                  fontSize: 15.sp,
                  color: effectiveTitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              Transform.rotate(
                angle: -math.pi / 2,
                child: SvgPicture.asset(
                  AppAssets.iconsArrowDown,
                  width: 14.r,
                  height: 14.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
