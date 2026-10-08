import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

import 'medical_center_details_page.dart';

class AllMedicalCentersPage extends StatelessWidget {
  final List<MedicalCenterEntity> medicalCenters;

  const AllMedicalCentersPage({
    super.key,
    required this.medicalCenters,
  });

  void _openMedicalCenterDetails(BuildContext context,
      MedicalCenterEntity center,) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MedicalCenterDetailsPage(
              center: center,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: AppColors.darkTeal,
          ),
        ),
        title: Text(
          'Medical Centers',
          style: AppTextStyles.inter16W500.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: medicalCenters.isEmpty
          ? Center(
        child: Text(
          'No medical centers found.',
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W400,
            AppColors.gray500,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: NearbyMedicalCenters(
          isAdmin: false,
          isVertical: true,
          onSeeAllPressed: null,
          medicalCenters: medicalCenters
              .map(
                (center) =>
                MedicalCenterData(
                  id: center.id,
                  name: center.name,
                  category: center.type,
                  address: center.address,
                  rating: center.rating,
                  reviewCount: center.reviewsCount,
                  distance: center.formattedDistance,
                  type: center.type,
                  imagePath: center.imagePath,
                ),
          )
              .toList(),
          onCenterTap: (centerData) {
            final centerId = centerData.id;

            if (centerId == null || centerId.isEmpty) {
              return;
            }

            MedicalCenterEntity? selectedCenter;

            for (final center in medicalCenters) {
              if (center.id == centerId) {
                selectedCenter = center;
                break;
              }
            }

            if (selectedCenter == null) {
              return;
            }

            _openMedicalCenterDetails(
              context,
              selectedCenter,
            );
          },
        ),
      ),
    );
  }
}