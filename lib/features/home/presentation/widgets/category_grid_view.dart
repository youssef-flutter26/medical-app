import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/features/home/presentation/widgets/category_card.dart';
import 'package:medical_app/features/home/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';

/// A soft, harmonious accent pair for a category card.
///
/// [base] tints the artwork tile, [ink] is the saturated tone used for the
/// fallback icon and the edit affordance.
class CategoryAccent {
  const CategoryAccent(this.base, this.ink);

  final Color base;
  final Color ink;
}

const List<CategoryAccent> _categoryPalette = [
  CategoryAccent(Color(0xFFE0F2FE), Color(0xFF0284C7)),
  CategoryAccent(Color(0xFFDCFCE7), Color(0xFF16A34A)),
  CategoryAccent(Color(0xFFFEE2E2), Color(0xFFDC2626)),
  CategoryAccent(Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  CategoryAccent(Color(0xFFFEF3C7), Color(0xFFD97706)),
  CategoryAccent(Color(0xFFD1FAE5), Color(0xFF059669)),
  CategoryAccent(Color(0xFFE0E7FF), Color(0xFF4F46E5)),
  CategoryAccent(Color(0xFFFFE4E6), Color(0xFFE11D48)),
  CategoryAccent(Color(0xFFCFFAFE), Color(0xFF0891B2)),
  CategoryAccent(Color(0xFFECFDF5), Color(0xFF047857)),
];

/// Resolves the accent for [category] from its stable Firestore identity.
///
/// Deriving the accent from the id (falling back to the name) instead of the
/// list index keeps a category's colour identical across reloads, re-sorts and
/// renames, so the card always harmonises with the artwork it was shown with.
CategoryAccent categoryAccentFor(CategoryEntity category) {
  final id = category.id?.trim() ?? '';
  final key = id.isNotEmpty ? id : category.name.trim();
  var hash = 0;
  for (final unit in key.toLowerCase().codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return _categoryPalette[hash % _categoryPalette.length];
}

class CategoryGridView extends StatelessWidget {
  final List<CategoryEntity>? categories;
  final List<CategoryData>? legacyCategories;
  final ValueChanged<CategoryEntity>? onCategoryTap;
  final ValueChanged<String>? onLegacyCategoryTap;
  final bool isAdmin;
  final ValueChanged<CategoryEntity>? onEditCategory;

  const CategoryGridView({
    super.key,
    this.categories,
    this.legacyCategories,
    this.onCategoryTap,
    this.onLegacyCategoryTap,
    this.isAdmin = false,
    this.onEditCategory,
  });

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
        separatorBuilder: (_, _) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          final category = categories![index];
          final accent = categoryAccentFor(category);
          return CategoryCard(
            title: category.name,
            imagePath: category.imagePath,
            backgroundColor: accent.base,
            iconColor: accent.ink,
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
      separatorBuilder: (_, _) => SizedBox(height: 14.h),
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