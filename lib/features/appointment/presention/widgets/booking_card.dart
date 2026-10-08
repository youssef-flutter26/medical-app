import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReschedule,
    this.onReBook,
    this.onAddReview,
    this.onCardTap,
  });

  final AppointmentEntity appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onReBook;
  final VoidCallback? onAddReview;
  final VoidCallback? onCardTap;

  String get _displayDate {
    final dt = appointment.dateTime;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;

    final hour24 = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);

    return '$month $day, $year - ${hour12.toString().padLeft(2, '0')}.$minute $period';
  }

  Widget _buildDoctorImage(String? imagePath) {
    const defaultAsset = 'assets/images/Doctor_1.png';
    final resolvedPath = (imagePath != null && imagePath.isNotEmpty)
        ? imagePath
        : defaultAsset;

    Widget imageWidget;
    if (resolvedPath.startsWith('http://') || resolvedPath.startsWith('https://')) {
      imageWidget = Image.network(
        resolvedPath,
        width: 74.w,
        height: 74.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImagePlaceholder(),
      );
    } else {
      final assetPath = resolvedPath.startsWith('assets/')
          ? resolvedPath
          : 'assets/images/$resolvedPath';
      imageWidget = Image.asset(
        assetPath,
        width: 74.w,
        height: 74.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImagePlaceholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: imageWidget,
    );
  }

  Widget _fallbackImagePlaceholder() {
    return Container(
      width: 74.w,
      height: 74.w,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.gray400,
          size: 36,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = appointment.status.toLowerCase() == 'upcoming' ||
        appointment.status.toLowerCase() == 'booked';
    final isCompleted = appointment.status.toLowerCase() == 'completed';
    final isCanceled = appointment.status.toLowerCase() == 'canceled' ||
        appointment.status.toLowerCase() == 'cancelled';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
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
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Date Row
            Text(
              _displayDate,
              style: AppTextStyles.inter14W500.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTeal,
              ),
            ),

            // Divider Line
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF1F5F9),
              ),
            ),

            // Doctor Info Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildDoctorImage(appointment.doctorImagePath),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: AppTextStyles.inter16W500.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTeal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        appointment.doctorSpecialty ?? 'General Specialist',
                        style: AppTextStyles.inter12W400.copyWith(
                          fontSize: 13.sp,
                          color: AppColors.gray500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.iconsLocation,
                            width: 13.w,
                            height: 13.w,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray400,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              appointment.doctorAddress ?? 'Medical Clinic, USA',
                              style: AppTextStyles.inter12W400.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.gray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Bottom Buttons Section
            if (isUpcoming) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.gray600,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.cancel.tr(),
                          style: AppTextStyles.inter14W500.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: onReschedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.reschedule.tr(),
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
            ] else if (isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: onReBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.gray600,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.reBook.tr(),
                          style: AppTextStyles.inter14W500.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: onAddReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.addReview.tr(),
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
            ] else if (isCanceled) ...[
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: onReBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.reBook.tr(),
                    style: AppTextStyles.inter14W500.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
