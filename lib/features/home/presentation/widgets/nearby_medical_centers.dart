import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final bool isFavorite;

  const MedicalCenterData({
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.isFavorite = false,
  });
}

class NearbyMedicalCenters extends StatelessWidget {
  const NearbyMedicalCenters({
    super.key,
    this.onSeeAllPressed,
    this.onCenterTap,
    this.onFavoriteTap,
  });

  final VoidCallback? onSeeAllPressed;
  final ValueChanged<MedicalCenterData>? onCenterTap;
  final ValueChanged<MedicalCenterData>? onFavoriteTap;

  static const List<MedicalCenterData> centers = [
    MedicalCenterData(
      name: 'Sunrise Health Clinic',
      category: 'Hospital • Multi-Specialty',
      address: '123 Oak Street, NY',
      rating: 4.8,
      reviewCount: 120,
      distance: '2.5 km',
      isFavorite: true,
    ),
    MedicalCenterData(
      name: 'Golden Cardio...',
      category: 'Cardiology Specialist',
      address: '554 Pine Avenue, NY',
      rating: 4.9,
      reviewCount: 85,
      distance: '1.8 km',
      isFavorite: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Medical Centers',
              style: AppTextStyles.withColor(
                AppTextStyles.inter16W500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                AppColors.darkTeal,
              ),
            ),
            InkWell(
              onTap: onSeeAllPressed,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  'See All',
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter12W500,
                    AppColors.primary600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 205.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: centers.length,
            separatorBuilder: (context, index) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final center = centers[index];
              return MedicalCenterItem(
                name: center.name,
                category: center.category,
                address: center.address,
                rating: center.rating,
                reviewCount: center.reviewCount,
                distance: center.distance,
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
