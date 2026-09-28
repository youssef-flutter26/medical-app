import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';

class MedicalCenterData {
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String distance;
  final String? duration;
  final String? type;
  final String? imagePath;
  final String? imageUrl;
  final bool isFavorite;

  const MedicalCenterData({
    required this.name,
    this.category = '',
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.duration,
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
    this.onSeeAllPressed,
    this.onCenterTap,
    this.onFavoriteTap,
  });

  final List<MedicalCenterData>? medicalCenters;
  final VoidCallback? onSeeAllPressed;
  final ValueChanged<MedicalCenterData>? onCenterTap;
  final ValueChanged<MedicalCenterData>? onFavoriteTap;

  static const List<MedicalCenterData> defaultCenters = [
    MedicalCenterData(
      name: 'Sunrise Health Clinic',
      category: 'Hospital • Multi-Specialty',
      address: '123 Oak Street, CA 98765',
      rating: 5.0,
      reviewCount: 58,
      distance: '2.5 km/40min',
      duration: '40min',
      type: 'Hospital',
      imagePath: 'assets/images/medical_center_1.png',
      isFavorite: false,
    ),
    MedicalCenterData(
      name: 'Golden Cardiology Center',
      category: 'Cardiology Specialist',
      address: '555 Bridge Street, Golden Gate',
      rating: 4.9,
      reviewCount: 108,
      distance: '2.5 km/40min',
      duration: '40min',
      type: 'Clinic',
      imagePath: 'assets/images/medical_center_2.png',
      isFavorite: false,
    ),
  ];

  static const List<MedicalCenterData> centers = defaultCenters;

  @override
  Widget build(BuildContext context) {
    final list = medicalCenters ?? centers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
            InkWell(
              onTap: onSeeAllPressed,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
        SizedBox(height: 12.h),
        SizedBox(
          height: 325.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: list.length,
            separatorBuilder: (context, index) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final center = list[index];
              return MedicalCenterItem(
                name: center.name,
                category: center.category,
                address: center.address,
                rating: center.rating,
                reviewCount: center.reviewCount,
                distance: center.distance,
                duration: center.duration,
                type: center.type,
                imagePath: center.imagePath,
                imageUrl: center.imageUrl,
                isFavorite: center.isFavorite,
                onTap: () => onCenterTap?.call(center),
                onFavoriteTap: () => onFavoriteTap?.call(center),
              );
            },
          ),
        ),
      ],
    );
  }
}
