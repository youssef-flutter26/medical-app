import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CategoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CategoryAppBar({
    super.key,
    this.title,
    this.onBackPressed,
  });

  final String? title;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      title: Text(
        title ?? LocaleKeys.allCategories.tr(),
        style: AppTextStyles.inter16W500,
      ),
      centerTitle: false,
    );
  }
}
