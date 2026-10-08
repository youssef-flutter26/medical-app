import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

enum BookingStatus { initial, loading, success, failure }

class AppointmentState extends Equatable {
  const AppointmentState({
    required this.doctor,
    required this.selectedDate,
    this.selectedTime,
    this.bookedSlots = const {},
    this.isLoadingSlots = false,
    this.bookingStatus = BookingStatus.initial,
    this.errorMessage,
  });

  final DoctorEntity doctor;
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final Set<String> bookedSlots;
  final bool isLoadingSlots;
  final BookingStatus bookingStatus;
  final String? errorMessage;

  AppointmentState copyWith({
    DoctorEntity? doctor,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    bool clearSelectedTime = false,
    Set<String>? bookedSlots,
    bool? isLoadingSlots,
    BookingStatus? bookingStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AppointmentState(
      doctor: doctor ?? this.doctor,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime:
          clearSelectedTime ? null : (selectedTime ?? this.selectedTime),
      bookedSlots: bookedSlots ?? this.bookedSlots,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        doctor,
        selectedDate,
        selectedTime,
        bookedSlots,
        isLoadingSlots,
        bookingStatus,
        errorMessage,
      ];
}
