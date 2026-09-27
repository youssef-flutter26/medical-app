import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/presentation/widgets/category_item.dart';

class CategoryData {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const CategoryData({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
    this.onSeeAllPressed,
    this.onCategoryTap,
  });

  final VoidCallback? onSeeAllPressed;
  final ValueChanged<String>? onCategoryTap;

  static const List<CategoryData> categories = [
    CategoryData(
      title: 'Dentistry',
      icon: Icons.cleaning_services_rounded,
      backgroundColor: Color(0xFFF0FDF4),
      iconColor: Color(0xFF16A34A),
    ),
    CategoryData(
      title: 'Cardiology',
      icon: Icons.favorite_rounded,
      backgroundColor: Color(0xFFFEF2F2),
      iconColor: Color(0xFFDC2626),
    ),
    CategoryData(
      title: 'Pulmonology',
      icon: Icons.air_rounded,
      backgroundColor: Color(0xFFEFF6FF),
      iconColor: Color(0xFF2563EB),
    ),
    CategoryData(
      title: 'General',
      icon: Icons.local_hospital_rounded,
      backgroundColor: Color(0xFFFAF5FF),
      iconColor: Color(0xFF9333EA),
    ),
    CategoryData(
      title: 'Neurology',
      icon: Icons.psychology_rounded,
      backgroundColor: Color(0xFFFFFBEB),
      iconColor: Color(0xFFD97706),
    ),
    CategoryData(
      title: 'Gastro...',
      icon: Icons.medication_liquid_rounded,
      backgroundColor: Color(0xFFECFDF5),
      iconColor: Color(0xFF059669),
    ),
    CategoryData(
      title: 'Laboratory',
      icon: Icons.biotech_rounded,
      backgroundColor: Color(0xFFF0F9FF),
      iconColor: Color(0xFF0284C7),
    ),
    CategoryData(
      title: 'Vaccination',
      icon: Icons.vaccines_rounded,
      backgroundColor: Color(0xFFFFF1F2),
      iconColor: Color(0xFFE11D48),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: AppTextStyles.withColor(
                AppTextStyles.inter16W500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                AppColors.darkTeal,
              ),
            ),
            InkWell(
              onTap: onSeeAllPressed,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  'See All',
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter12W500,
                    AppColors.primary600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryItem(
              title: category.title,
              icon: category.icon,
              backgroundColor: category.backgroundColor,
              iconColor: category.iconColor,
              onTap: () => onCategoryTap?.call(category.title),
            );
          },
        ),
      ],
    );
  }
}
