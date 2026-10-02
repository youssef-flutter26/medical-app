import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/features/category/presentation/widgets/category_card.dart';
import 'package:medical_app/features/category/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';

class CategoryGridView extends StatelessWidget {
  const CategoryGridView({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<CategoryData> categories;
  final ValueChanged<String>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const CategoryEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          title: category.title,
          icon: category.icon,
          backgroundColor: category.backgroundColor,
          iconColor: category.iconColor,
          onTap: () => onCategoryTap?.call(category.title),
        );
      },
    );
  }
}
