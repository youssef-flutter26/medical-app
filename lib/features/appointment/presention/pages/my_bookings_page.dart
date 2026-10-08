import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/presention/pages/book_appointment_page.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_card.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_empty_state.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_tab_bar.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/reviews/presentation/cubit/review_cubit.dart';
import 'package:medical_app/features/reviews/presentation/pages/add_review_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({
    super.key,
    this.initialAppointments,
    this.initialTab = BookingTab.upcoming,
  });

  final List<AppointmentEntity>? initialAppointments;
  final BookingTab initialTab;

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late BookingTab _selectedTab;
  late List<AppointmentEntity> _appointments;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _appointments = widget.initialAppointments != null
        ? List<AppointmentEntity>.from(widget.initialAppointments!)
        : _createDefaultBookings();
  }

  List<AppointmentEntity> _createDefaultBookings() {
    return [
      // Upcoming bookings (exact match to design)
      AppointmentEntity(
        id: 'up_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. James Robinson',
        doctorSpecialty: 'Orthopedic Surgery',
        doctorAddress: 'Elite Ortho Clinic, USA',
        doctorImagePath: 'assets/images/Doctor_1.png',
        dateTime: DateTime(2023, 5, 22, 10, 0),
        dateKey: '2023-05-22',
        time: '10.00 AM',
        status: 'upcoming',
        patientId: 'patient_1',
      ),
      AppointmentEntity(
        id: 'up_2',
        doctorId: 'doc_2',
        doctorName: 'Dr. Daniel Lee',
        doctorSpecialty: 'Gastroenterologist',
        doctorAddress: 'Digestive Institute, USA',
        doctorImagePath: 'assets/images/Doctor_2.png',
        dateTime: DateTime(2023, 6, 14, 15, 0),
        dateKey: '2023-06-14',
        time: '15.00 PM',
        status: 'upcoming',
        patientId: 'patient_1',
      ),
      AppointmentEntity(
        id: 'up_3',
        doctorId: 'doc_3',
        doctorName: 'Dr. Nathan Harris',
        doctorSpecialty: 'Orthopedic Surgery',
        doctorAddress: 'Elite Ortho Clinic, USA',
        doctorImagePath: 'assets/images/Doctor_3.png',
        dateTime: DateTime(2023, 6, 21, 10, 0),
        dateKey: '2023-06-21',
        time: '10.00 AM',
        status: 'upcoming',
        patientId: 'patient_1',
      ),

      // Completed bookings (exact match to design)
      AppointmentEntity(
        id: 'comp_1',
        doctorId: 'doc_4',
        doctorName: 'Dr. Sarah Johnson',
        doctorSpecialty: 'Gynecologist',
        doctorAddress: "Women's Health Clinic",
        doctorImagePath: 'assets/images/Doctor_4.png',
        dateTime: DateTime(2023, 3, 12, 11, 0),
        dateKey: '2023-03-12',
        time: '11.00 AM',
        status: 'completed',
        patientId: 'patient_1',
      ),
      AppointmentEntity(
        id: 'comp_2',
        doctorId: 'doc_5',
        doctorName: 'Dr. Michael Chang',
        doctorSpecialty: 'Cardiologist',
        doctorAddress: 'HeartCare Center, USA',
        doctorImagePath: 'assets/images/Doctor_5.png',
        dateTime: DateTime(2023, 3, 2, 0, 0),
        dateKey: '2023-03-02',
        time: '12.00 AM',
        status: 'completed',
        patientId: 'patient_1',
      ),
      AppointmentEntity(
        id: 'comp_3',
        doctorId: 'doc_6',
        doctorName: 'Dr. David Martinez',
        doctorSpecialty: 'Pediatrician',
        doctorAddress: "Children's Health Clinic",
        doctorImagePath: 'assets/images/Doctor_6.png',
        dateTime: DateTime(2023, 2, 2, 9, 0),
        dateKey: '2023-02-02',
        time: '09.00 AM',
        status: 'completed',
        patientId: 'patient_1',
      ),

      // Canceled booking
      AppointmentEntity(
        id: 'canc_1',
        doctorId: 'doc_7',
        doctorName: 'Dr. Emily Watson',
        doctorSpecialty: 'Neurologist',
        doctorAddress: 'Metro Health Clinic',
        doctorImagePath: 'assets/images/Doctor_7.png',
        dateTime: DateTime(2023, 1, 15, 14, 0),
        dateKey: '2023-01-15',
        time: '14.00 PM',
        status: 'canceled',
        patientId: 'patient_1',
      ),
    ];
  }

  List<AppointmentEntity> get _filteredAppointments {
    switch (_selectedTab) {
      case BookingTab.upcoming:
        return _appointments.where((a) {
          final s = a.status.toLowerCase();
          return s == 'upcoming' || s == 'booked';
        }).toList();
      case BookingTab.completed:
        return _appointments.where((a) {
          return a.status.toLowerCase() == 'completed';
        }).toList();
      case BookingTab.canceled:
        return _appointments.where((a) {
          final s = a.status.toLowerCase();
          return s == 'canceled' || s == 'cancelled';
        }).toList();
    }
  }

  DoctorEntity _buildDoctorEntity(AppointmentEntity appointment) {
    return DoctorEntity(
      id: appointment.doctorId,
      name: appointment.doctorName,
      specialty: appointment.doctorSpecialty ?? 'General Specialist',
      categoryId: '',
      categoryName: appointment.doctorSpecialty ?? 'General Specialist',
      address: appointment.doctorAddress ?? 'Medical Clinic, USA',
      rating: 4.8,
      reviewsCount: 120,
      availableTime: '09:00 AM - 05:00 PM',
      imagePath: appointment.doctorImagePath ?? 'assets/images/Doctor_1.png',
    );
  }

  Future<void> _handleCancelBooking(AppointmentEntity appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            LocaleKeys.cancel.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkTeal,
            ),
          ),
          content: Text(
            LocaleKeys.cancelBookingConfirmation.tr(),
            style: AppTextStyles.inter14W400.copyWith(
              color: AppColors.gray600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: AppTextStyles.inter14W500.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                LocaleKeys.ok.tr(),
                style: AppTextStyles.inter14W500.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        final index = _appointments.indexWhere((a) => a.id == appointment.id);
        if (index != -1) {
          _appointments[index] = appointment.copyWith(status: 'canceled');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.bookingCanceledSuccessfully.tr()),
          backgroundColor: AppColors.darkTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  void _handleReschedule(AppointmentEntity appointment) {
    final doctor = _buildDoctorEntity(appointment);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentPage(doctor: doctor),
      ),
    );
  }

  void _handleReBook(AppointmentEntity appointment) {
    final doctor = _buildDoctorEntity(appointment);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentPage(doctor: doctor),
      ),
    );
  }

  void _handleAddReview(AppointmentEntity appointment) {
    if (getIt.isRegistered<ReviewCubit>()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ReviewCubit>(),
            child: AddReviewPage(
              targetId: appointment.doctorId,
              targetName: appointment.doctorName,
              targetType: 'doctor',
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddReviewPage(
            targetId: appointment.doctorId,
            targetName: appointment.doctorName,
            targetType: 'doctor',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _filteredAppointments;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          LocaleKeys.myBookings.tr(),
          style: AppTextStyles.inter18W700.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 6.h),

            // Tab Bar
            BookingTabBar(
              selectedTab: _selectedTab,
              onTabChanged: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),

            SizedBox(height: 12.h),

            // Content List
            Expanded(
              child: currentList.isEmpty
                  ? BookingEmptyState(
                      message: _getEmptyStateMessage(),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final appointment = currentList[index];
                        return BookingCard(
                          appointment: appointment,
                          onCancel: () => _handleCancelBooking(appointment),
                          onReschedule: () => _handleReschedule(appointment),
                          onReBook: () => _handleReBook(appointment),
                          onAddReview: () => _handleAddReview(appointment),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedTab) {
      case BookingTab.upcoming:
        return LocaleKeys.noUpcomingBookings.tr();
      case BookingTab.completed:
        return LocaleKeys.noCompletedBookings.tr();
      case BookingTab.canceled:
        return LocaleKeys.noCanceledBookings.tr();
    }
  }
}

typedef AppointmentScreen = MyBookingsPage;
