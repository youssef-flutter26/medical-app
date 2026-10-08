import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_card.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_empty_state.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_tab_bar.dart';

class BookingListView extends StatelessWidget {
  const BookingListView({
    super.key,
    required this.selectedTab,
    required this.appointments,
    required this.onCancel,
    required this.onReschedule,
    required this.onReBook,
    required this.onAddReview,
  });

  final BookingTab selectedTab;
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppointmentEntity> onCancel;
  final ValueChanged<AppointmentEntity> onReschedule;
  final ValueChanged<AppointmentEntity> onReBook;
  final ValueChanged<AppointmentEntity> onAddReview;

  String _emptyMessageForTab(BookingTab tab) {
    switch (tab) {
      case BookingTab.upcoming:
        return LocaleKeys.noUpcomingBookings.tr();
      case BookingTab.completed:
        return LocaleKeys.noCompletedBookings.tr();
      case BookingTab.canceled:
        return LocaleKeys.noCanceledBookings.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return BookingEmptyState(
        message: _emptyMessageForTab(selectedTab),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 8.h,
      ),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return BookingCard(
          appointment: appointment,
          onCancel: () => onCancel(appointment),
          onReschedule: () => onReschedule(appointment),
          onReBook: () => onReBook(appointment),
          onAddReview: () => onAddReview(appointment),
        );
      },
    );
  }
}
