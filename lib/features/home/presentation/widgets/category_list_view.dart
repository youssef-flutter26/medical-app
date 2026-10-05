import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/features/home/presentation/widgets/category_card.dart';
import 'package:medical_app/features/home/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

/// Renders every category as a compact full-width card stacked vertically.
///
/// Intentionally a list, never a grid, so each category gets a comfortable row
/// for its artwork, name and admin-only edit affordance.
class CategoryListView extends StatelessWidget {
  final List<CategoryEntity>? categories;
  final List<CategoryData>? legacyCategories;
  final ValueChanged<CategoryEntity>? onCategoryTap;
  final ValueChanged<String>? onLegacyCategoryTap;
  final bool isAdmin;
  final ValueChanged<CategoryEntity>? onEditCategory;

  const CategoryListView({
    super.key,
    this.categories,
    this.legacyCategories,
    this.onCategoryTap,
    this.onLegacyCategoryTap,
    this.isAdmin = false,
    this.onEditCategory,
  });

  static final double _gap = 16.h;

  @override
  Widget build(BuildContext context) {
    if (categories != null) {
      if (categories!.isEmpty) {
        return const CategoryEmptyState();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: categories!.length,
        separatorBuilder: (_, _) => SizedBox(height: _gap),
        itemBuilder: (context, index) {
          final category = categories![index];
          return CategoryCard(
            title: category.name,
            imagePath: category.imagePath,
            isAdmin: isAdmin,
            onEdit: onEditCategory != null
                ? () => onEditCategory!(category)
                : null,
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: list.length,
      separatorBuilder: (_, _) => SizedBox(height: _gap),
      itemBuilder: (context, index) {
        final category = list[index];
        return CategoryCard(
          title: category.title,
          icon: category.icon,
          imagePath: category.imagePath,
          onTap: () => onLegacyCategoryTap?.call(category.title),
        );
      },
    );
  }
}
