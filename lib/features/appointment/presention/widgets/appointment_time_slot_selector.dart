import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class AppointmentTimeSlotSelector extends StatelessWidget {
  const AppointmentTimeSlotSelector({
    super.key,
    required this.selectedDate,
    required this.slots,
    required this.bookedSlots,
    required this.selectedTime,
    required this.isLoadingSlots,
    required this.onTimeSelected,
    this.hasDoctorAvailability = true,
  });

  final DateTime selectedDate;
  final List<TimeOfDay> slots;
  final Set<String> bookedSlots;
  final TimeOfDay? selectedTime;
  final bool isLoadingSlots;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool hasDoctorAvailability;

  static String _timeKey(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _isPastSlot(DateTime date, TimeOfDay time) {
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return !slotDateTime.isAfter(DateTime.now());
  }

  Widget _buildTimeSlot(TimeOfDay time) {
    final key = _timeKey(time);
    final isBooked = bookedSlots.contains(key);
    final isPast = _isPastSlot(selectedDate, time);
    final isSelected = selectedTime != null && _timeKey(selectedTime!) == key;
    final isDisabled = isBooked || isPast;

    return InkWell(
      onTap: isDisabled ? null : () => onTimeSelected(time),
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.gray100
              : isSelected
                  ? AppColors.darkTeal
                  : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDisabled
                ? const Color(0xFFE2E8F0)
                : isSelected
                    ? AppColors.darkTeal
                    : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.darkTeal.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(time),
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isDisabled
                        ? AppColors.gray400
                        : isSelected
                            ? AppColors.white
                            : AppColors.darkTeal,
                  ),
                ),
                if (isBooked) ...[
                  SizedBox(height: 2.h),
                  Text(
                    LocaleKeys.booked.tr(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray400,
                    ),
                  ),
                ] else if (isPast) ...[
                  SizedBox(height: 2.h),
                  Text(
                    LocaleKeys.passed.tr(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.selectHour.tr(),
          style: AppTextStyles.inter14W500.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: 10.h),
        if (isLoadingSlots)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkTeal,
              ),
            ),
          )
        else if (slots.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              hasDoctorAvailability
                  ? LocaleKeys.noAvailableSlots.tr()
                  : LocaleKeys.doctorNoAvailability.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.inter12W400.copyWith(
                color: AppColors.gray500,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 2.1,
            ),
            itemCount: slots.length,
            itemBuilder: (_, index) {
              return _buildTimeSlot(slots[index]);
            },
          ),
      ],
    );
  }
}
