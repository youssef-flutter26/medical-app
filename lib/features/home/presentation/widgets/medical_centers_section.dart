import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

class MedicalCentersSection extends StatelessWidget {
  final List<MedicalCenterEntity>? medicalCenters;
  final bool isLoading;
  final String? errorMessage;
  final bool isAdmin;
  final ValueChanged<MedicalCenterEntity>? onEditCenter;
  final VoidCallback? onSeeAll;
  final ValueChanged<MedicalCenterEntity>? onCenterTap;

  const MedicalCentersSection({
    super.key,
    this.medicalCenters,
    this.isLoading = false,
    this.errorMessage,
    this.isAdmin = false,
    this.onEditCenter,
    this.onSeeAll,
    this.onCenterTap,
  });

  void _handleEditCenter(BuildContext context, MedicalCenterData centerData) {
    if (onEditCenter == null) return;

    final list = medicalCenters ?? const <MedicalCenterEntity>[];
    final entity = list.firstWhere(
      (c) =>
          (centerData.id != null && c.id == centerData.id) ||
          (c.name == centerData.name && c.address == centerData.address),
      orElse: () => MedicalCenterEntity(
        id: centerData.id,
        name: centerData.name,
        address: centerData.address,
        rating: centerData.rating,
        reviewsCount: centerData.reviewCount,
        distance: double.tryParse(
              RegExp(r'[0-9]+(?:\.[0-9]+)?')
                      .firstMatch(centerData.distance)
                      ?.group(0) ??
                  '',
            ) ??
            0.0,
        duration: int.tryParse(
              RegExp(r'[0-9]+')
                      .firstMatch(centerData.duration ?? '')
                      ?.group(0) ??
                  '',
            ) ??
            0,
        type: centerData.type ?? centerData.category,
        imagePath: centerData.imagePath ?? '',
      ),
    );

    onEditCenter!(entity);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Error state
    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.nearbyMedicalCenters.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            alignment: Alignment.center,
            child: Text(
              'Error loading medical centers: $errorMessage',
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400,
                Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    // 2. Loading state
    if (isLoading && medicalCenters == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.nearbyMedicalCenters.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 218.h,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkTeal,
              ),
            ),
          ),
        ],
      );
    }

    // 3. Success state
    final list = medicalCenters ?? const <MedicalCenterEntity>[];

    return NearbyMedicalCenters(
      isAdmin: isAdmin,
      onSeeAllPressed: onSeeAll,
      onCenterTap: (centerData) {
        if (onCenterTap != null) {
          final matched = list.firstWhere(
            (c) =>
                (centerData.id != null && c.id == centerData.id) ||
                (c.name == centerData.name && c.address == centerData.address),
            orElse: () => MedicalCenterEntity(
              id: centerData.id,
              name: centerData.name,
              address: centerData.address,
              rating: centerData.rating,
              reviewsCount: centerData.reviewCount,
              distance: double.tryParse(
                    RegExp(r'[0-9]+(?:\.[0-9]+)?')
                            .firstMatch(centerData.distance)
                            ?.group(0) ??
                        '',
                  ) ??
                  0.0,
              duration: int.tryParse(
                    RegExp(r'[0-9]+')
                            .firstMatch(centerData.duration ?? '')
                            ?.group(0) ??
                        '',
                  ) ??
                  0,
              type: centerData.type ?? centerData.category,
              imagePath: centerData.imagePath ?? '',
            ),
          );
          onCenterTap!(matched);
        }
      },
      onEditCenter: (centerData) => _handleEditCenter(context, centerData),
      medicalCenters: list
          .map(
            (c) => MedicalCenterData(
              id: c.id,
              name: c.name,
              category: c.type,
              address: c.address,
              rating: c.rating,
              reviewCount: c.reviewsCount,
              distance: c.formattedDistance,
              duration: c.formattedDuration,
              type: c.type,
              imagePath: c.imagePath,
            ),
          )
          .toList(),
    );
  }
}
