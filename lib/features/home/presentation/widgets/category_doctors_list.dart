import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/presentation/widgets/doctor_card.dart';

class CategoryDoctorsList extends StatelessWidget {
  final List<DoctorData> doctors;
  final ValueChanged<DoctorData>? onDoctorTap;
  final ValueChanged<DoctorData>? onFavoriteTap;
  final bool isAdmin;
  final ValueChanged<DoctorData>? onEditDoctor;

  const CategoryDoctorsList({
    super.key,
    required this.doctors,
    this.onDoctorTap,
    this.onFavoriteTap,
    this.isAdmin = false,
    this.onEditDoctor,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 48.h),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 48.r,
              color: AppColors.gray400,
            ),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.noDoctorsFound.tr(),
              style: AppTextStyles.inter16W500.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return DoctorCard(
          doctor: doctor,
          onTap: () => onDoctorTap?.call(doctor),
          onFavoriteTap: () => onFavoriteTap?.call(doctor),
          isAdmin: isAdmin,
          onEdit: onEditDoctor != null ? () => onEditDoctor!(doctor) : null,
        );
      },
    );
  }
}
