import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class AppointmentDateSelector extends StatelessWidget {
  const AppointmentDateSelector({
    super.key,
    required this.selectedDate,
    required this.isDateSelectable,
    required this.onDateSelected,
    this.hasDoctorAvailability = true,
  });

  final DateTime selectedDate;
  final bool Function(DateTime date) isDateSelectable;
  final ValueChanged<DateTime> onDateSelected;
  final bool hasDoctorAvailability;

  static const List<String> _months = [
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

  String _monthName(DateTime date) => _months[date.month - 1];

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime get _calendarMonth =>
      DateTime(selectedDate.year, selectedDate.month, 1);

  void _goToPreviousMonth() {
    final previous = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);
    final today = _dateOnly(DateTime.now());

    if (previous.isBefore(DateTime(today.year, today.month, 1))) {
      return;
    }

    final target = _findFirstSelectableDateInMonth(previous);
    onDateSelected(target);
  }

  void _goToNextMonth() {
    final next = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);
    final target = _findFirstSelectableDateInMonth(next);
    onDateSelected(target);
  }

  DateTime _findFirstSelectableDateInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final today = _dateOnly(DateTime.now());

    for (DateTime date = first;
        !date.isAfter(last);
        date = date.add(const Duration(days: 1))) {
      if (date.isBefore(today)) {
        continue;
      }
      if (isDateSelectable(date)) {
        return date;
      }
    }

    return first.isBefore(today) ? today : first;
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          Text(
            '${_monthName(selectedDate)} ${selectedDate.year}',
            style: AppTextStyles.inter14W500.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 24.r,
              color: AppColors.gray600,
            ),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 24.r,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.selectDate.tr(),
          style: AppTextStyles.inter14W500.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.gray700,
          ),
        ),
        if (!hasDoctorAvailability) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFFFEDD5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 18.r,
                  color: const Color(0xFFD97706),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    LocaleKeys.doctorNoAvailability.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0x08000000),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              _buildCalendarHeader(),
              Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.darkTeal,
                    onPrimary: AppColors.white,
                    surface: AppColors.white,
                    onSurface: AppColors.darkTeal,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final today = _dateOnly(DateTime.now());
                    final safeInitial = selectedDate.isBefore(today) ? today : selectedDate;
                    final safePredicate = (hasDoctorAvailability && isDateSelectable(safeInitial))
                        ? isDateSelectable
                        : null;

                    return CalendarDatePicker(
                      initialDate: safeInitial,
                      firstDate: today,
                      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                      currentDate: DateTime.now(),
                      selectableDayPredicate: safePredicate,
                      onDateChanged: onDateSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
