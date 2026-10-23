import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medical_app/features/appointment/presention/pages/book_appointment_page.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_tab_bar.dart';
import 'package:medical_app/features/appointment/presention/widgets/cancel_booking_dialog.dart';
import 'package:medical_app/features/reviews/presentation/cubit/review_cubit.dart';
import 'package:medical_app/features/reviews/presentation/pages/add_review_page.dart';

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
    this.repository,
  });

  final AppointmentEntity appointment;
  final AppointmentRepository? repository;

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late AppointmentEntity _appointment;
  bool _isCanceling = false;

  AppointmentRepository? get _repository {
    if (widget.repository != null) return widget.repository;
    if (getIt.isRegistered<AppointmentRepository>()) {
      return getIt<AppointmentRepository>();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  String get _displayDate {
    final dt = _appointment.dateTime;
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

    return '$month $day, $year - ${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _handleCancel() async {
    final confirmed = await CancelBookingDialog.show(context);
    if (confirmed != true || !mounted) return;

    setState(() => _isCanceling = true);

    final repo = _repository;
    if (repo != null && _appointment.id != null && _appointment.id!.isNotEmpty) {
      await repo.cancelAppointment(_appointment.id!);
    }

    if (!mounted) return;
    setState(() {
      _isCanceling = false;
      _appointment = _appointment.copyWith(status: 'canceled');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appointment cancelled successfully.'),
        backgroundColor: AppColors.darkTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _handleReschedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentPage.fromAppointment(
          existingAppointment: _appointment,
        ),
      ),
    );
  }

  void _handleReBook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentPage.fromDoctorId(
          doctorId: _appointment.doctorId,
        ),
      ),
    );
  }

  void _handleAddReview() {
    if (getIt.isRegistered<ReviewCubit>()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ReviewCubit>(),
            child: AddReviewPage(
              targetId: _appointment.doctorId,
              targetName: _appointment.doctorName,
              targetType: 'doctor',
            ),
          ),
        ),
      );
    }
  }

  void _navigateToMyBookings() {
    final status = _appointment.status.toLowerCase();
    final tab = (status == 'canceled' || status == 'cancelled')
        ? BookingTab.canceled
        : (status == 'completed'
            ? BookingTab.completed
            : BookingTab.upcoming);

    Navigator.pushNamed(
      context,
      Routes.myBookings,
      arguments: tab,
    );
  }

  Widget _buildDoctorImage(String? imagePath) {
    const defaultAsset = 'assets/images/Doctor_1.png';
    final resolvedPath = (imagePath != null && imagePath.isNotEmpty)
        ? imagePath
        : defaultAsset;

    Widget imageWidget;
    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      imageWidget = Image.network(
        resolvedPath,
        width: 72.w,
        height: 72.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackImagePlaceholder(),
      );
    } else {
      final assetPath = resolvedPath.startsWith('assets/')
          ? resolvedPath
          : 'assets/images/$resolvedPath';
      imageWidget = Image.asset(
        assetPath,
        width: 72.w,
        height: 72.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackImagePlaceholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: imageWidget,
    );
  }

  Widget _fallbackImagePlaceholder() {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(14.r),
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

  Widget _buildStatusBanner() {
    final status = _appointment.status.toLowerCase();
    Color bgColor;
    Color textColor;
    IconData icon;
    String statusTitle;
    String statusSubtitle;

    if (status == 'canceled' || status == 'cancelled') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      icon = Icons.cancel_outlined;
      statusTitle = 'Appointment Cancelled';
      statusSubtitle =
          'This appointment has been cancelled. You can re-book anytime.';
    } else if (status == 'rescheduled') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
      icon = Icons.update_rounded;
      statusTitle = 'Appointment Rescheduled';
      statusSubtitle =
          'Your appointment schedule has been successfully updated.';
    } else if (status == 'completed') {
      bgColor = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF4F46E5);
      icon = Icons.check_circle_outline_rounded;
      statusTitle = 'Appointment Completed';
      statusSubtitle =
          'This appointment has ended. We hope you had a good experience.';
    } else {
      bgColor = const Color(0xFFE6F4EA);
      textColor = const Color(0xFF137333);
      icon = Icons.check_circle_rounded;
      statusTitle = 'Appointment Confirmed';
      statusSubtitle =
          'Your appointment has been successfully booked with the doctor.';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: AppTextStyles.inter16W500.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusSubtitle,
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 12.sp,
                    color: textColor.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _appointment.status.toLowerCase();
    final isUpcoming = status == 'upcoming' ||
        status == 'booked' ||
        status == 'rescheduled';
    final isCanceled = status == 'canceled' || status == 'cancelled';
    final isCompleted = status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkTeal,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appointment Details',
          style: AppTextStyles.inter16W500.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),
            SizedBox(height: 20.h),

            // Doctor Card
            Container(
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
              child: Row(
                children: [
                  _buildDoctorImage(_appointment.doctorImagePath),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appointment.doctorName.isNotEmpty
                              ? _appointment.doctorName
                              : 'Doctor',
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
                          _appointment.doctorSpecialty ?? 'Specialist',
                          style: AppTextStyles.inter12W400.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_appointment.doctorAddress != null &&
                            _appointment.doctorAddress!.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.iconsLocation,
                                width: 12.w,
                                height: 12.w,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.gray400,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  _appointment.doctorAddress!,
                                  style: AppTextStyles.inter12W400.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.gray500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Schedule Information
            Text(
              'Scheduled Date & Time',
              style: AppTextStyles.inter16W500.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.darkTeal,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayDate,
                          style: AppTextStyles.inter14W500.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        if (_appointment.id != null) ...[
                          SizedBox(height: 3.h),
                          Text(
                            'Booking ID: #${_appointment.id}',
                            style: AppTextStyles.inter12W400.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // Action Buttons
            if (isUpcoming) ...[
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _handleReschedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reschedule Appointment',
                    style: AppTextStyles.inter14W500.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: _isCanceling ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: _isCanceling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFEF4444),
                          ),
                        )
                      : Text(
                          'Cancel Appointment',
                          style: AppTextStyles.inter14W500.copyWith(
                            color: const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                ),
              ),
            ] else if (isCanceled) ...[
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _handleReBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Re-Book Appointment',
                    style: AppTextStyles.inter14W500.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ] else if (isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _handleAddReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add Review',
                    style: AppTextStyles.inter14W500.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: _handleReBook,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Book Again',
                    style: AppTextStyles.inter14W500.copyWith(
                      color: AppColors.darkTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: TextButton(
                onPressed: _navigateToMyBookings,
                child: Text(
                  'View in My Bookings',
                  style: AppTextStyles.inter14W500.copyWith(
                    color: AppColors.darkTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
