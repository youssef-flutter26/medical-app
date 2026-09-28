import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class BannerImageUrlField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const BannerImageUrlField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.imageUrl.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W500,
            AppColors.gray700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: TextInputType.url,
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W400,
            AppColors.gray700,
          ),
          decoration: InputDecoration(
            hintText: LocaleKeys.enterImageUrl.tr(),
            hintStyle: AppTextStyles.withColor(
              AppTextStyles.inter14W400,
              AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.gray400.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.gray400.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.lightTeal,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.red,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
