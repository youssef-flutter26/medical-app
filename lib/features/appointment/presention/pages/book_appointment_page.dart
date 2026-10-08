import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_cubit.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_state.dart';
import 'package:medical_app/features/appointment/presention/widgets/appointment_date_selector.dart';
import 'package:medical_app/features/appointment/presention/widgets/appointment_time_slot_selector.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_summary.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_success_dialog.dart';
import 'package:medical_app/features/appointment/presention/widgets/confirm_booking_button.dart';
import 'package:medical_app/features/appointment/presention/widgets/doctor_summary_card.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_doctor_by_id.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({
    super.key,
    required this.doctor,
    this.existingAppointment,
    this.cubit,
  }) : doctorId = null;

  BookAppointmentPage.fromAppointment({
    super.key,
    required AppointmentEntity this.existingAppointment,
    this.cubit,
  })  : doctor = null,
        doctorId = existingAppointment.doctorId;

  const BookAppointmentPage.fromDoctorId({
    super.key,
    required String this.doctorId,
    this.existingAppointment,
    this.cubit,
  }) : doctor = null;

  final DoctorEntity? doctor;
  final String? doctorId;
  final AppointmentEntity? existingAppointment;
  final AppointmentCubit? cubit;

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DoctorEntity? _loadedDoctor;
  bool _isLoadingDoctor = false;
  String? _doctorError;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _loadedDoctor = widget.doctor;
    } else if (widget.doctorId != null && widget.doctorId!.isNotEmpty) {
      _fetchDoctor(widget.doctorId!);
    }
  }

  Future<void> _fetchDoctor(String doctorId) async {
    setState(() {
      _isLoadingDoctor = true;
      _doctorError = null;
    });

    try {
      if (getIt.isRegistered<GetDoctorById>()) {
        final result = await getIt<GetDoctorById>()(doctorId);
        if (!mounted) return;
        switch (result) {
          case SuccessAPI(:final data):
            if (data != null) {
              setState(() {
                _loadedDoctor = data;
                _isLoadingDoctor = false;
              });
              return;
            } else {
              setState(() {
                _doctorError = LocaleKeys.doctorNotFound.tr();
                _isLoadingDoctor = false;
              });
              return;
            }
          case ErrorAPI(:final failure):
            setState(() {
              _doctorError = failure.message;
              _isLoadingDoctor = false;
            });
            return;
        }
      } else {
        setState(() {
          _doctorError = LocaleKeys.doctorNotFound.tr();
          _isLoadingDoctor = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _doctorError = e.toString();
        _isLoadingDoctor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDoctor) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.r,
              color: AppColors.gray700,
            ),
          ),
          title: Text(
            widget.existingAppointment != null
                ? LocaleKeys.rescheduleAppointment.tr()
                : LocaleKeys.bookAppointment.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.darkTeal,
          ),
        ),
      );
    }

    if (_doctorError != null || _loadedDoctor == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.r,
              color: AppColors.gray700,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48.r,
                  color: AppColors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  _doctorError ?? LocaleKeys.doctorNotFound.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.inter14W500.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(LocaleKeys.back.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final doctor = _loadedDoctor!;

    return BlocProvider(
      create: (_) =>
          widget.cubit ??
          getIt<AppointmentCubit>(
            param1: doctor,
            param2: widget.existingAppointment,
          ),
      child: _BookAppointmentView(
        isRescheduling: widget.existingAppointment != null,
      ),
    );
  }
}

class _BookAppointmentView extends StatelessWidget {
  const _BookAppointmentView({
    required this.isRescheduling,
  });

  final bool isRescheduling;

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
              isRescheduling
                  ? LocaleKeys.rescheduleAppointment.tr()
                  : LocaleKeys.bookAppointment.tr(),
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
                        hasDoctorAvailability: cubit.hasDoctorAvailability,
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
                label: isRescheduling
                    ? LocaleKeys.reschedule.tr()
                    : LocaleKeys.confirm.tr(),
                onPressed: cubit.bookAppointment,
              ),
            ],
          ),
        );
      },
    );
  }
}
