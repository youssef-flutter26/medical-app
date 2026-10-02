import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CategorySearchField extends StatelessWidget {
  const CategorySearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.inter14W400,
        decoration: InputDecoration(
          hintText: LocaleKeys.searchCategory.tr(),
          hintStyle: AppTextStyles.withColor(
            AppTextStyles.inter14W400,
            AppColors.gray400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.gray400,
            size: 20.r,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.gray400,
                    size: 18.r,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}
