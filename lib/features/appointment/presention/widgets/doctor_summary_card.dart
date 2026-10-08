import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class DoctorSummaryCard extends StatelessWidget {
  const DoctorSummaryCard({
    super.key,
    required this.doctor,
  });

  final DoctorEntity doctor;

  Widget _buildDoctorImage(String imagePath) {
    const defaultAsset = 'assets/images/Doctor_1.png';
    final resolvedPath = imagePath.isNotEmpty ? imagePath : defaultAsset;

    Widget imageWidget;
    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      imageWidget = Image.network(
        resolvedPath,
        width: 60.w,
        height: 60.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackImagePlaceholder(),
      );
    } else {
      final assetPath = resolvedPath.startsWith('assets/')
          ? resolvedPath
          : 'assets/images/$resolvedPath';
      imageWidget = Image.asset(
        assetPath,
        width: 60.w,
        height: 60.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackImagePlaceholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: imageWidget,
    );
  }

  Widget _fallbackImagePlaceholder() {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.gray400,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDoctorImage(doctor.imagePath),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: AppTextStyles.inter16W500.copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  doctor.specialty,
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (doctor.address.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.iconsLocation,
                        width: 12.w,
                        height: 12.w,
                        colorFilter: const ColorFilter.mode(
                          AppColors.gray400,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          doctor.address,
                          style: AppTextStyles.inter12W400.copyWith(
                            fontSize: 11.sp,
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
