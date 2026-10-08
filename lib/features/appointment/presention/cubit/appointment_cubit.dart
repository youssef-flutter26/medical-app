import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/usecases/book_appointment.dart';
import 'package:medical_app/features/appointment/domain/usecases/get_booked_slots.dart';
import 'package:medical_app/features/appointment/domain/usecases/reschedule_appointment.dart';
import 'package:medical_app/features/home/data/models/doctor_model.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit({
    required DoctorEntity doctor,
    this.existingAppointment,
    required BookAppointment bookAppointment,
    RescheduleAppointment? rescheduleAppointment,
    required GetBookedSlots getBookedSlots,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _bookAppointment = bookAppointment,
        _rescheduleAppointment = rescheduleAppointment,
        _getBookedSlots = getBookedSlots,
        _auth = auth,
        _firestore = firestore,
        super(
          AppointmentState(
            doctor: doctor,
            selectedDate: _resolveInitialDate(doctor, existingAppointment),
            selectedTime: _resolveInitialTime(existingAppointment),
          ),
        ) {
    loadBookedSlots();
    syncDoctorFromFirestore();
  }

  final AppointmentEntity? existingAppointment;
  final BookAppointment _bookAppointment;
  final RescheduleAppointment? _rescheduleAppointment;
  final GetBookedSlots _getBookedSlots;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  bool get isRescheduling => existingAppointment != null;

  FirebaseAuth? get _authInstance {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestoreInstance {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  void emit(AppointmentState state) {
    if (isClosed) return;
    super.emit(state);
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dayKeyFromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return 'sunday';
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      default:
        return 'sunday';
    }
  }

  static TimeOfDay? _parseTimeString(String timeStr) {
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(' ');
    final timeComponent = parts[0];
    final colonParts = timeComponent.split(':');
    if (colonParts.length != 2) return null;

    int? hour = int.tryParse(colonParts[0]);
    final int? minute = int.tryParse(colonParts[1]);
    if (hour == null || minute == null) return null;

    if (parts.length > 1) {
      final period = parts[1].toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static DoctorSchedule? getScheduleForDate(
    DoctorEntity doctor,
    DateTime date,
  ) {
    final day = dayKeyFromDate(date);
    for (final schedule in doctor.schedule) {
      if (schedule.day.toLowerCase() == day) {
        return schedule;
      }
    }
    return null;
  }

  static bool isDoctorAvailableOnDay(DoctorEntity doctor, DateTime date) {
    final schedule = getScheduleForDate(doctor, date);
    if (schedule == null || !schedule.enabled) {
      return false;
    }
    final start = _parseTimeString(schedule.startTime);
    final end = _parseTimeString(schedule.endTime);
    if (start == null || end == null) {
      return false;
    }
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return startMinutes < endMinutes;
  }

  static bool isDateSelectableStatic(DoctorEntity doctor, DateTime date) {
    final today = _dateOnly(DateTime.now());
    final selected = _dateOnly(date);
    if (selected.isBefore(today)) {
      return false;
    }
    return isDoctorAvailableOnDay(doctor, selected);
  }

  static DateTime _resolveInitialDate(
    DoctorEntity doctor,
    AppointmentEntity? existingAppointment,
  ) {
    final today = _dateOnly(DateTime.now());
    if (existingAppointment != null) {
      final apptDate = _dateOnly(existingAppointment.dateTime);
      if (!apptDate.isBefore(today) && isDoctorAvailableOnDay(doctor, apptDate)) {
        return apptDate;
      }
    }
    return _getFirstAvailableDateStatic(doctor);
  }

  static TimeOfDay? _resolveInitialTime(
    AppointmentEntity? existingAppointment,
  ) {
    if (existingAppointment == null) return null;
    return _parseTimeString(existingAppointment.time);
  }

  static DateTime _getFirstAvailableDateStatic(DoctorEntity doctor) {
    final today = _dateOnly(DateTime.now());
    for (int i = 0; i < 60; i++) {
      final date = today.add(Duration(days: i));
      if (isDoctorAvailableOnDay(doctor, date)) {
        return date;
      }
    }
    return today;
  }

  bool isDateSelectable(DateTime date) {
    return isDateSelectableStatic(state.doctor, date);
  }

  bool get hasDoctorAvailability {
    return state.doctor.schedule.any((s) {
      if (!s.enabled) return false;
      final start = _parseTimeString(s.startTime);
      final end = _parseTimeString(s.endTime);
      if (start == null || end == null) return false;
      return (start.hour * 60 + start.minute) < (end.hour * 60 + end.minute);
    });
  }

  static String timeKey(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  static String dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static bool isPastSlot(DateTime date, TimeOfDay time) {
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return !slotDateTime.isAfter(DateTime.now());
  }

  List<TimeOfDay> getAvailableTimeSlotsForSelectedDate() {
    final schedule = getScheduleForDate(state.doctor, state.selectedDate);
    if (schedule == null || !schedule.enabled) {
      return [];
    }

    final startTime = _parseTimeString(schedule.startTime);
    final endTime = _parseTimeString(schedule.endTime);

    if (startTime == null || endTime == null) {
      return [];
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes >= endMinutes) {
      return [];
    }

    int currentMinutes = startMinutes;
    final slots = <TimeOfDay>[];

    while (currentMinutes < endMinutes) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;
      slots.add(TimeOfDay(hour: hour, minute: minute));
      currentMinutes += 30;
    }

    return slots;
  }

  Future<void> syncDoctorFromFirestore() async {
    final doctorId = state.doctor.id;
    if (doctorId == null || doctorId.isEmpty) return;

    try {
      final firestore = _firestoreInstance;
      if (firestore == null) return;
      final snapshot =
          await firestore.collection('doctors').doc(doctorId).get();
      if (snapshot.exists && snapshot.data() != null) {
        final liveDoctor =
            DoctorModel.fromFirestore(snapshot.data()!, snapshot.id);
        if (!isClosed) {
          final updatedDate =
              _resolveInitialDate(liveDoctor, existingAppointment);
          final updatedTime = state.selectedTime ??
              _resolveInitialTime(existingAppointment);
          emit(
            state.copyWith(
              doctor: liveDoctor,
              selectedDate: updatedDate,
              selectedTime: updatedTime,
            ),
          );
          await loadBookedSlots();
        }
      }
    } catch (_) {
      // Graceful fallback to existing passed Doctor entity
    }
  }

  Future<void> selectDate(DateTime date) async {
    if (!isDateSelectable(date)) {
      return;
    }

    emit(
      state.copyWith(
        selectedDate: _dateOnly(date),
        clearSelectedTime: true,
        bookedSlots: {},
        clearErrorMessage: true,
      ),
    );

    await loadBookedSlots();
  }

  void selectTime(TimeOfDay time) {
    emit(
      state.copyWith(
        selectedTime: time,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> loadBookedSlots() async {
    final doctorId = state.doctor.id;
    if (doctorId == null || doctorId.isEmpty) {
      emit(
        state.copyWith(
          bookedSlots: {},
          isLoadingSlots: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoadingSlots: true));

    final result = await _getBookedSlots(
      doctorId: doctorId,
      dateKey: dateKey(state.selectedDate),
    );

    switch (result) {
      case SuccessAPI(:final data):
        final userSlot = (existingAppointment != null &&
                _dateOnly(existingAppointment!.dateTime) == state.selectedDate)
            ? existingAppointment!.time
            : null;
        final availableData = userSlot != null
            ? (data.toSet()..remove(userSlot))
            : data;

        TimeOfDay? updatedSelectedTime = state.selectedTime;
        if (updatedSelectedTime != null &&
            availableData.contains(timeKey(updatedSelectedTime))) {
          updatedSelectedTime = null;
        }

        emit(
          state.copyWith(
            bookedSlots: availableData,
            isLoadingSlots: false,
            selectedTime: updatedSelectedTime,
            clearSelectedTime: updatedSelectedTime == null,
          ),
        );

      case ErrorAPI(:final failure):
        emit(
          state.copyWith(
            bookedSlots: {},
            isLoadingSlots: false,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> bookAppointment() async {
    if (state.bookingStatus == BookingStatus.loading) {
      return;
    }

    if (state.selectedTime == null) {
      emit(
        state.copyWith(
          bookingStatus: BookingStatus.failure,
          errorMessage: LocaleKeys.pleaseSelectTime,
        ),
      );
      return;
    }

    final doctorId = state.doctor.id;
    if (doctorId == null || doctorId.isEmpty) {
      emit(
        state.copyWith(
          bookingStatus: BookingStatus.failure,
          errorMessage: LocaleKeys.doctorInfoIncomplete,
        ),
      );
      return;
    }

    final user = _authInstance?.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          bookingStatus: BookingStatus.failure,
          errorMessage: LocaleKeys.pleaseLoginFirst,
        ),
      );
      return;
    }

    final selectedTime = state.selectedTime!;
    final timeFormatted = timeKey(selectedTime);

    if (state.bookedSlots.contains(timeFormatted)) {
      emit(
        state.copyWith(
          bookingStatus: BookingStatus.failure,
          errorMessage: LocaleKeys.slotAlreadyBooked,
        ),
      );
      await loadBookedSlots();
      return;
    }

    if (isPastSlot(state.selectedDate, selectedTime)) {
      emit(
        state.copyWith(
          bookingStatus: BookingStatus.failure,
          errorMessage: LocaleKeys.slotPassed,
        ),
      );
      return;
    }

    emit(state.copyWith(bookingStatus: BookingStatus.loading));

    final appointmentDateTime = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (existingAppointment != null && _rescheduleAppointment != null) {
      final res = await _rescheduleAppointment(
        appointmentId: existingAppointment!.id ?? '',
        dateKey: dateKey(state.selectedDate),
        time: timeFormatted,
        dateTime: appointmentDateTime,
      );

      switch (res) {
        case SuccessAPI():
          emit(state.copyWith(bookingStatus: BookingStatus.success));
        case ErrorAPI(:final failure):
          emit(
            state.copyWith(
              bookingStatus: BookingStatus.failure,
              errorMessage: failure.message,
            ),
          );
          await loadBookedSlots();
      }
      return;
    }

    final result = await _bookAppointment(
      doctorId: doctorId,
      doctorName: state.doctor.name,
      patientId: user.uid,
      dateKey: dateKey(state.selectedDate),
      time: timeFormatted,
      dateTime: appointmentDateTime,
      doctorSpecialty: state.doctor.specialty,
      doctorAddress: state.doctor.address,
      doctorImagePath: state.doctor.imagePath,
    );

    switch (result) {
      case SuccessAPI():
        emit(state.copyWith(bookingStatus: BookingStatus.success));

      case ErrorAPI(:final failure):
        emit(
          state.copyWith(
            bookingStatus: BookingStatus.failure,
            errorMessage: failure.message,
          ),
        );
        await loadBookedSlots();
    }
  }

  void resetBookingStatus() {
    emit(
      state.copyWith(
        bookingStatus: BookingStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }
}
