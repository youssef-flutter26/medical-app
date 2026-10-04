import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class HomeSearch extends StatelessWidget {
  const HomeSearch({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onFilterTap,
    this.onClear,
  });

  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? LocaleKeys.searchDoctor.tr();
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.iconsSearchNormal,
            width: 24.r,
            height: 24.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400.copyWith(fontSize: 14.sp),
                AppColors.darkTeal,
              ),
              decoration: InputDecoration(
                hintText: effectiveHint,
                hintStyle: AppTextStyles.withColor(
                  AppTextStyles.inter14W400.copyWith(fontSize: 14.sp),
                  AppColors.gray400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller!.clear();
                onChanged?.call('');
                onClear?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.r,
                  color: AppColors.gray400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
