import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/doctor_card.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';

class DoctorsSection extends StatelessWidget {
  final List<DoctorEntity>? doctors;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onSeeAll;
  final ValueChanged<DoctorEntity>? onDoctorTap;

  const DoctorsSection({
    super.key,
    this.doctors,
    this.isLoading = false,
    this.errorMessage,
    this.onSeeAll,
    this.onDoctorTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Error state
    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(showSeeAll: false),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            alignment: Alignment.center,
            child: Text(
              'Error loading doctors: $errorMessage',
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
    if (isLoading && doctors == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(showSeeAll: false),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkTeal,
              ),
            ),
          ),
        ],
      );
    }

    // 3. Data / Empty state
    final list = doctors ?? const <DoctorEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(showSeeAll: list.isNotEmpty),
        SizedBox(height: 12.h),
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.noDoctorsFound.tr(),
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400,
                AppColors.gray500,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final doc = list[index];
              return DoctorCard(
                doctor: DoctorData.fromEntity(doc),
                onTap: () => onDoctorTap?.call(doc),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader({required bool showSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            LocaleKeys.allDoctors.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.darkTeal,
            ),
          ),
        ),
        if (showSeeAll)
          InkWell(
            onTap: onSeeAll,
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
    );
  }
}
