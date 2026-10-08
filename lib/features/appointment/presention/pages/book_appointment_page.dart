import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_cubit.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_state.dart';
import 'package:medical_app/features/appointment/presention/widgets/appointment_date_selector.dart';
import 'package:medical_app/features/appointment/presention/widgets/appointment_time_slot_selector.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_summary.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_success_dialog.dart';
import 'package:medical_app/features/appointment/presention/widgets/confirm_booking_button.dart';
import 'package:medical_app/features/appointment/presention/widgets/doctor_summary_card.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class BookAppointmentPage extends StatelessWidget {
  const BookAppointmentPage({
    super.key,
    required this.doctor,
    this.cubit,
  });

  final DoctorEntity doctor;
  final AppointmentCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => cubit ?? getIt<AppointmentCubit>(param1: doctor),
      child: const _BookAppointmentView(),
    );
  }
}

class _BookAppointmentView extends StatelessWidget {
  const _BookAppointmentView();

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

  String _formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showSuccessDialog(
    BuildContext context,
    AppointmentState state,
  ) {
    final selectedTime = state.selectedTime;
    if (selectedTime == null) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return BookingSuccessDialog(
          doctorName: state.doctor.name,
          formattedDate: _formatDate(state.selectedDate),
          formattedTime: _formatTime(selectedTime),
          onDone: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }

  void _showError(BuildContext context, String? message) {
    final displayMessage = (message != null && message.isNotEmpty)
        ? (message.tr())
        : LocaleKeys.bookingFailed.tr();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentCubit, AppointmentState>(
      listenWhen: (previous, current) =>
          previous.bookingStatus != current.bookingStatus,
      listener: (context, state) {
        if (state.bookingStatus == BookingStatus.success) {
          _showSuccessDialog(context, state);
        } else if (state.bookingStatus == BookingStatus.failure) {
          _showError(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AppointmentCubit>();
        final slots = cubit.getAvailableTimeSlotsForSelectedDate();

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.r,
                color: AppColors.gray700,
              ),
            ),
            title: Text(
              LocaleKeys.bookAppointment.tr(),
              style: AppTextStyles.inter16W500.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DoctorSummaryCard(doctor: state.doctor),
                      SizedBox(height: 18.h),
                      AppointmentDateSelector(
                        selectedDate: state.selectedDate,
                        isDateSelectable: cubit.isDateSelectable,
                        onDateSelected: cubit.selectDate,
                        hasDoctorAvailability: cubit.hasDoctorAvailability,
                      ),
                      SizedBox(height: 20.h),
                      AppointmentTimeSlotSelector(
                        selectedDate: state.selectedDate,
                        slots: slots,
                        bookedSlots: state.bookedSlots,
                        selectedTime: state.selectedTime,
                        isLoadingSlots: state.isLoadingSlots,
                        onTimeSelected: cubit.selectTime,
                        hasDoctorAvailability: cubit.hasDoctorAvailability,
                      ),
                      SizedBox(height: 20.h),
                      BookingSummary(
                        doctor: state.doctor,
                        selectedDate: state.selectedDate,
                        selectedTime: state.selectedTime,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              ConfirmBookingButton(
                isBooking: state.bookingStatus == BookingStatus.loading,
                isTimeSelected: state.selectedTime != null,
                isLoadingSlots: state.isLoadingSlots,
                onPressed: cubit.bookAppointment,
              ),
            ],
          ),
        );
      },
    );
  }
}
