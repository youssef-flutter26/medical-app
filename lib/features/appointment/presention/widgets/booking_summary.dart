import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class BookingSummary extends StatelessWidget {
  const BookingSummary({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    this.hasDoctorAvailability = true,
  });

  final DoctorEntity doctor;
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final bool hasDoctorAvailability;

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedTime = selectedTime != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasSelectedTime
              ? AppColors.darkTeal.withValues(alpha: 0.15)
              : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 20.r,
                color: hasSelectedTime ? AppColors.darkTeal : AppColors.gray400,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  LocaleKeys.bookingSummary.tr(),
                  style: AppTextStyles.inter14W500.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: hasSelectedTime
                        ? const Color(0xFFE8F5E9)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      hasSelectedTime
                          ? LocaleKeys.readyToConfirm.tr()
                          : LocaleKeys.pleaseSelectSlotToProceed.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: hasSelectedTime
                            ? const Color(0xFF2E7D32)
                            : AppColors.gray500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                LocaleKeys.appointmentDate.tr(),
                style: AppTextStyles.inter12W400.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  hasDoctorAvailability
                      ? _formatDate(selectedDate)
                      : '-- / -- / ----',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: hasDoctorAvailability
                        ? AppColors.darkTeal
                        : AppColors.gray400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                LocaleKeys.appointmentTime.tr(),
                style: AppTextStyles.inter12W400.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  hasSelectedTime ? _formatTime(selectedTime!) : '-- : --',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: hasSelectedTime
                        ? AppColors.darkTeal
                        : AppColors.gray400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
