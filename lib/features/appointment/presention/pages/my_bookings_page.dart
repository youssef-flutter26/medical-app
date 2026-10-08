import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medical_app/features/appointment/presention/pages/book_appointment_page.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_list_view.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_tab_bar.dart';
import 'package:medical_app/features/appointment/presention/widgets/cancel_booking_dialog.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/reviews/presentation/cubit/review_cubit.dart';
import 'package:medical_app/features/reviews/presentation/pages/add_review_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({
    super.key,
    this.initialAppointments,
    this.initialTab = BookingTab.upcoming,
    this.auth,
    this.repository,
  });

  final List<AppointmentEntity>? initialAppointments;
  final BookingTab initialTab;
  final FirebaseAuth? auth;
  final AppointmentRepository? repository;

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late BookingTab _selectedTab;
  List<AppointmentEntity> _appointments = const [];
  StreamSubscription<List<AppointmentEntity>>? _subscription;
  bool _isLoading = false;

  FirebaseAuth? get _authInstance {
    if (widget.auth != null) return widget.auth;
    if (getIt.isRegistered<FirebaseAuth>()) {
      return getIt<FirebaseAuth>();
    }
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  AppointmentRepository? get _repositoryInstance {
    if (widget.repository != null) return widget.repository;
    if (getIt.isRegistered<AppointmentRepository>()) {
      return getIt<AppointmentRepository>();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    if (widget.initialAppointments != null) {
      _appointments = List<AppointmentEntity>.from(widget.initialAppointments!);
      _isLoading = false;
    } else {
      _setupRealAppointmentsStream();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupRealAppointmentsStream() {
    final auth = _authInstance;
    final user = auth?.currentUser;
    final repo = _repositoryInstance;

    if (user == null || repo == null) {
      setState(() {
        _appointments = const [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _subscription = repo.streamUserAppointments(user.uid).listen(
      (appointments) {
        if (!mounted) return;
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
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
      specialty: appointment.doctorSpecialty ?? '',
      categoryId: '',
      categoryName: appointment.doctorSpecialty ?? '',
      address: appointment.doctorAddress ?? '',
      rating: 0.0,
      reviewsCount: 0,
      availableTime: '',
      imagePath: appointment.doctorImagePath ?? '',
    );
  }

  Future<void> _handleCancelBooking(AppointmentEntity appointment) async {
    final confirmed = await CancelBookingDialog.show(context);
    if (confirmed != true || !mounted) return;

    setState(() {
      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        final updated = List<AppointmentEntity>.from(_appointments);
        updated[index] = appointment.copyWith(status: 'canceled');
        _appointments = updated;
      }
    });

    final repo = _repositoryInstance;
    if (repo != null && appointment.id != null && appointment.id!.isNotEmpty) {
      await repo.cancelAppointment(appointment.id!);
    }

    if (!mounted) return;
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
            BookingTabBar(
              selectedTab: _selectedTab,
              onTabChanged: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkTeal,
                      ),
                    )
                  : BookingListView(
                      selectedTab: _selectedTab,
                      appointments: currentList,
                      onCancel: _handleCancelBooking,
                      onReschedule: _handleReschedule,
                      onReBook: _handleReBook,
                      onAddReview: _handleAddReview,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef AppointmentScreen = MyBookingsPage;
