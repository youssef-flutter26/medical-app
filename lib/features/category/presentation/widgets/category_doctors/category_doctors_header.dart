import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class CategoryDoctorsHeader extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearSearch;
  final int resultsCount;
  final VoidCallback? onSortTap;

  const CategoryDoctorsHeader({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onClearSearch,
    required this.resultsCount,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.iconsSearchNormal,
                width: 20.r,
                height: 20.r,
                colorFilter: const ColorFilter.mode(
                  AppColors.gray400,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: AppTextStyles.inter14W400.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.darkTeal,
                  ),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.searchDoctor.tr(),
                    hintStyle: AppTextStyles.inter14W400.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.gray400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (searchController != null &&
                  searchController!.text.isNotEmpty)
                InkWell(
                  onTap: () {
                    searchController!.clear();
                    onClearSearch?.call();
                    onSearchChanged?.call('');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.r,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$resultsCount ${LocaleKeys.founds.tr()}',
              style: AppTextStyles.inter16W500.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
            ),
            InkWell(
              onTap: onSortTap,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.defaultSort.tr(),
                      style: AppTextStyles.inter14W500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.swap_vert_rounded,
                      size: 18.r,
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
