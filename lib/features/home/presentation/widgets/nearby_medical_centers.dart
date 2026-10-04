import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';

class MedicalCenterData {
  final String? id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String distance;
  final String? type;
  final String? imagePath;
  final String? imageUrl;
  final bool isFavorite;

  const MedicalCenterData({
    this.id,
    required this.name,
    this.category = '',
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.type,
    this.imagePath,
    this.imageUrl,
    this.isFavorite = false,
  });
}

class NearbyMedicalCenters extends StatelessWidget {
  const NearbyMedicalCenters({
    super.key,
    this.medicalCenters,
    this.isAdmin = false,
    this.onSeeAllPressed,
    this.onCenterTap,
    this.onFavoriteTap,
    this.onEditCenter,
    this.isVertical = false,
  });

  final List<MedicalCenterData>? medicalCenters;
  final bool isAdmin;
  final VoidCallback? onSeeAllPressed;
  final ValueChanged<MedicalCenterData>? onCenterTap;
  final ValueChanged<MedicalCenterData>? onFavoriteTap;
  final ValueChanged<MedicalCenterData>? onEditCenter;

  // false = العرض الطبيعي في Home جنب بعض
  // true = العرض الرأسي في صفحة See All
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    final list = medicalCenters ?? const <MedicalCenterData>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isVertical)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.nearbyMedicalCenters.tr(),
                  style: AppTextStyles.inter16W500.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
              if (list.isNotEmpty)
                InkWell(
                  onTap: onSeeAllPressed,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
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

        if (!isVertical) SizedBox(height: 12.h),

        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 24.h,
            ),
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.contentNotFound.tr(),
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400,
                AppColors.gray500,
              ),
            ),
          )
        else
          if (isVertical)
          // ==========================================
          // See All → الكروت تحت بعض
          // ==========================================
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 14.h);
              },
              itemBuilder: (context, index) {
                final center = list[index];

                return MedicalCenterItem(
                  name: center.name,
                  category: center.category,
                  address: center.address,
                  rating: center.rating,
                  reviewCount: center.reviewCount,
                  distance: center.distance,
                  type: center.type,
                  imagePath: center.imagePath,
                  imageUrl: center.imageUrl,
                  isFavorite: center.isFavorite,
                  isAdmin: isAdmin,
                  onTap: () {
                    onCenterTap?.call(center);
                  },
                  onFavoriteTap: () {
                    onFavoriteTap?.call(center);
                  },
                  onEdit:
                  (isAdmin && onEditCenter != null)
                      ? () {
                    onEditCenter!(center);
                  }
                      : null,
                );
              },
            )
        else
          // ==========================================
          // Home → الكروت جنب بعض كما هي
          // ==========================================
          SizedBox(
            height: 218.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: list.length,
              separatorBuilder: (context, index) {
                return SizedBox(width: 14.w);
              },
              itemBuilder: (context, index) {
                final center = list[index];

                return MedicalCenterItem(
                  name: center.name,
                  category: center.category,
                  address: center.address,
                  rating: center.rating,
                  reviewCount: center.reviewCount,
                  distance: center.distance,
                  type: center.type,
                  imagePath: center.imagePath,
                  imageUrl: center.imageUrl,
                  isFavorite: center.isFavorite,
                  isAdmin: isAdmin,
                  onTap: () {
                    onCenterTap?.call(center);
                  },
                  onFavoriteTap: () {
                    onFavoriteTap?.call(center);
                  },
                  onEdit:
                  (isAdmin && onEditCenter != null)
                      ? () {
                    onEditCenter!(center);
                  }
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}