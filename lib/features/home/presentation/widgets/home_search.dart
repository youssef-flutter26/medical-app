import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class HomeSearch extends StatelessWidget {
  const HomeSearch({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onFilterTap,
  });

  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? LocaleKeys.searchDoctorHint.tr();
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 22.r,
            color: AppColors.gray400,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              style: AppTextStyles.withColor(
                AppTextStyles.inter12W500,
                AppColors.darkTeal,
              ),
              decoration: InputDecoration(
                hintText: effectiveHint,
                hintStyle: AppTextStyles.withColor(
                  AppTextStyles.inter12W500,
                  AppColors.gray400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.tune_rounded,
                size: 20.r,
                color: AppColors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
