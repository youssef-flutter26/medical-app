import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/features/home/presentation/widgets/category_card.dart';
import 'package:medical_app/features/home/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';

const List<({Color bg, Color icon})> _categoryPalette = [
  (bg: Color(0xFFF0FDF4), icon: Color(0xFF16A34A)),
  (bg: Color(0xFFFEF2F2), icon: Color(0xFFDC2626)),
  (bg: Color(0xFFEFF6FF), icon: Color(0xFF2563EB)),
  (bg: Color(0xFFFAF5FF), icon: Color(0xFF9333EA)),
  (bg: Color(0xFFFFFBEB), icon: Color(0xFFD97706)),
  (bg: Color(0xFFECFDF5), icon: Color(0xFF059669)),
  (bg: Color(0xFFF0F9FF), icon: Color(0xFF0284C7)),
  (bg: Color(0xFFFFF1F2), icon: Color(0xFFE11D48)),
];

class CategoryGridView extends StatelessWidget {
  final List<CategoryEntity>? categories;
  final List<CategoryData>? legacyCategories;
  final ValueChanged<CategoryEntity>? onCategoryTap;
  final ValueChanged<String>? onLegacyCategoryTap;

  const CategoryGridView({
    super.key,
    this.categories,
    this.legacyCategories,
    this.onCategoryTap,
    this.onLegacyCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories != null) {
      if (categories!.isEmpty) {
        return const CategoryEmptyState();
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final category = categories![index];
          final palette = _categoryPalette[index % _categoryPalette.length];
          return CategoryCard(
            title: category.name,
            imagePath: category.imagePath,
            backgroundColor: palette.bg,
            iconColor: palette.icon,
            onTap: () {
              onCategoryTap?.call(category);
              onLegacyCategoryTap?.call(category.name);
            },
          );
        },
      );
    }

    final list = legacyCategories ?? const <CategoryData>[];
    if (list.isEmpty) {
      return const CategoryEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final category = list[index];
        return CategoryCard(
          title: category.title,
          icon: category.icon,
          backgroundColor: category.backgroundColor,
          iconColor: category.iconColor,
          imagePath: category.imagePath,
          onTap: () => onLegacyCategoryTap?.call(category.title),
        );
      },
    );
  }
}
