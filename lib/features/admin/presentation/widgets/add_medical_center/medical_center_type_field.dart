import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class MedicalCenterTypeField extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const MedicalCenterTypeField({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('medical_center_type_dropdown'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.type.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W500,
            AppColors.gray700,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _TypeCard(
                type: 'Hospital',
                title: LocaleKeys.hospital.tr(),
                icon: Icons.local_hospital_rounded,
                isSelected: selectedType == 'Hospital',
                onTap: () => onTypeChanged('Hospital'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _TypeCard(
                type: 'Clinic',
                title: LocaleKeys.clinic.tr(),
                icon: Icons.medical_services_rounded,
                isSelected: selectedType == 'Clinic',
                onTap: () => onTypeChanged('Clinic'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String type;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.bannerBgStart : AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? AppColors.lightTeal
              : AppColors.gray400.withValues(alpha: 0.2),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('medical_center_type_option_$type'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20.r,
                  color: isSelected ? AppColors.lightTeal : AppColors.gray500,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.withColor(
                      AppTextStyles.inter14W500,
                      isSelected ? AppColors.darkTeal : AppColors.gray600,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16.r,
                    color: AppColors.lightTeal,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
