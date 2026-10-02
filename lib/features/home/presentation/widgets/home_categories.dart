import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/category_item.dart';

class CategoryData {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String? imagePath;

  const CategoryData({
    required this.title,
    this.icon = Icons.category_rounded,
    this.backgroundColor = const Color(0xFFF0FDF4),
    this.iconColor = AppColors.darkTeal,
    this.imagePath,
  });
}

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
    this.categories,
    this.onSeeAllPressed,
    this.onCategoryTap,
  });

  final List<CategoryEntity>? categories;
  final VoidCallback? onSeeAllPressed;
  final ValueChanged<String>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final list = categories ?? const <CategoryEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.categories.tr(),
              style: AppTextStyles.withColor(
                AppTextStyles.inter16W500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                AppColors.darkTeal,
              ),
            ),
            if (list.isNotEmpty)
              InkWell(
                onTap: onSeeAllPressed,
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    LocaleKeys.seeAll.tr(),
                    style: AppTextStyles.inter14W500.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 14.h),
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.noCategoriesFound.tr(),
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400,
                AppColors.gray500,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final category = list[index];
              return CategoryItem(
                title: category.name,
                imagePath: category.imagePath,
                onTap: () => onCategoryTap?.call(category.name),
              );
            },
          ),
      ],
    );
  }
}
