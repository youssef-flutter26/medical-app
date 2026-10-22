import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'favorite_doctor_card.dart';
import 'favorite_hospital_card.dart';

class RemoveFavoriteBottomSheet extends StatelessWidget {
  final DoctorEntity? doctor;
  final MedicalCenterEntity? medicalCenter;

  const RemoveFavoriteBottomSheet({
    super.key,
    this.doctor,
    this.medicalCenter,
  });

  static Future<bool?> show(
    BuildContext context, {
    DoctorEntity? doctor,
    MedicalCenterEntity? medicalCenter,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RemoveFavoriteBottomSheet(
        doctor: doctor,
        medicalCenter: medicalCenter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.removeFromFavorites.tr(),
              style: AppTextStyles.inter18W700.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            if (doctor != null)
              FavoriteDoctorCard(
                doctor: doctor!,
                onFavoriteTap: null,
                onTap: null,
              )
            else if (medicalCenter != null)
              FavoriteHospitalCard(
                center: medicalCenter!,
                onFavoriteTap: null,
                onTap: null,
              ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E7EB),
                        foregroundColor: AppColors.darkTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.cancel.tr(),
                        style: AppTextStyles.inter14W500.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkTeal,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.yesRemove.tr(),
                        style: AppTextStyles.inter14W500.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
