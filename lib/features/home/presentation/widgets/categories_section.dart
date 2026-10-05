import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';

class CategoriesSection extends StatelessWidget {
  final List<CategoryEntity>? categories;
  final bool isLoading;
  final String? errorMessage;
  final bool isAdmin;
  final ValueChanged<CategoryEntity>? onEditCategory;
  final VoidCallback? onSeeAllPressed;
  final ValueChanged<CategoryEntity>? onCategoryTap;

  const CategoriesSection({
    super.key,
    this.categories,
    this.isLoading = false,
    this.errorMessage,
    this.isAdmin = false,
    this.onEditCategory,
    this.onSeeAllPressed,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Error state
    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.categories.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            alignment: Alignment.center,
            child: Text(
              'Error loading categories: $errorMessage',
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400,
                Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    // 2. Loading state
    if (isLoading && categories == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.categories.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 88.h,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkTeal,
              ),
            ),
          ),
        ],
      );
    }

    // 3. Success state
    return HomeCategories(
      categories: categories ?? const <CategoryEntity>[],
      isAdmin: isAdmin,
      onEditCategory: onEditCategory,
      onSeeAllPressed: onSeeAllPressed,
      onCategoryTap: onCategoryTap,
    );
  }
}
