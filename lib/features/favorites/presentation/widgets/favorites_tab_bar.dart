import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class FavoritesTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FavoritesTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray100,
            width: 1.5.h,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 0,
              label: LocaleKeys.doctors.tr(),
              isSelected: selectedIndex == 0,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              context: context,
              index: 1,
              label: LocaleKeys.hospitals.tr(),
              isSelected: selectedIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onTabSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              label,
              style: AppTextStyles.inter14W500.copyWith(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.darkTeal : AppColors.gray400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: 2.5.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.darkTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
