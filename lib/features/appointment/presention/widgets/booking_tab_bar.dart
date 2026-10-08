import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

enum BookingTab { upcoming, completed, canceled }

class BookingTabBar extends StatelessWidget {
  const BookingTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final BookingTab selectedTab;
  final ValueChanged<BookingTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              tab: BookingTab.upcoming,
              label: LocaleKeys.upcoming.tr(),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              tab: BookingTab.completed,
              label: LocaleKeys.completed.tr(),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              tab: BookingTab.canceled,
              label: LocaleKeys.canceled.tr(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BookingTab tab,
    required String label,
  }) {
    final isSelected = selectedTab == tab;

    return InkWell(
      onTap: () => onTabChanged(tab),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.inter16W500.copyWith(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.darkTeal : AppColors.gray400,
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: isSelected ? 48.w : 0,
              height: 3.5.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
