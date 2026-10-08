import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/features/appointment/domain/usecases/book_appointment.dart';
import 'package:medical_app/features/appointment/domain/usecases/get_booked_slots.dart';
import 'package:medical_app/features/home/data/models/doctor_model.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit({
    required DoctorEntity doctor,
    required BookAppointment bookAppointment,
    required GetBookedSlots getBookedSlots,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _bookAppointment = bookAppointment,
        _getBookedSlots = getBookedSlots,
        _auth = auth,
        _firestore = firestore,
        super(
          AppointmentState(
            doctor: doctor,
            selectedDate: _getFirstAvailableDateStatic(doctor),
          ),
        ) {
    loadBookedSlots();
    syncDoctorFromFirestore();
  }

  final BookAppointment _bookAppointment;
  final GetBookedSlots _getBookedSlots;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

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

  static String? _to24Hour(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.isEmpty) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

  static DoctorSchedule? _getScheduleFromAvailableTime(
    String availableTime,
    String dayKey,
  ) {
    const dayOrder = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    if (availableTime.isEmpty) {
      return DoctorSchedule(
        day: dayKey,
        enabled: dayKey != 'sunday',
        startTime: '09:00',
        endTime: '17:00',
      );
    }

    try {
      final parts = availableTime.split(':');
      if (parts.length >= 2) {
        final daysPart = parts[0].toLowerCase();
        bool isDayEnabled = false;

        if (daysPart.contains('-')) {
          final dayRange = daysPart.split('-');
          final startAbbr = dayRange[0].trim();
          final endAbbr = dayRange[1].trim();

          final startIndex =
              dayOrder.indexWhere((d) => d.startsWith(startAbbr));
          final endIndex = dayOrder.indexWhere((d) => d.startsWith(endAbbr));

          if (startIndex != -1 && endIndex != -1) {
            final currentDayIndex = dayOrder.indexOf(dayKey);
            if (startIndex <= endIndex) {
              isDayEnabled = currentDayIndex >= startIndex &&
                  currentDayIndex <= endIndex;
            } else {
              isDayEnabled = currentDayIndex >= startIndex ||
                  currentDayIndex <= endIndex;
            }
          }
        } else {
          isDayEnabled = daysPart.contains(dayKey.substring(0, 3));
        }

        final timeRangePart =
            availableTime.substring(availableTime.indexOf(':') + 1).trim();
        final times = timeRangePart.split('-');
        if (times.length == 2) {
          final start24 = _to24Hour(times[0]);
          final end24 = _to24Hour(times[1]);
          if (start24 != null && end24 != null) {
            return DoctorSchedule(
              day: dayKey,
              enabled: isDayEnabled,
              startTime: start24,
              endTime: end24,
            );
          }
        }
      }
    } catch (_) {
      // Fallback
    }

    return DoctorSchedule(
      day: dayKey,
      enabled: dayKey != 'sunday',
      startTime: '09:00',
      endTime: '17:00',
    );
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

    final hasAnyEnabled = doctor.schedule.any((s) => s.enabled);
    if (!hasAnyEnabled) {
      return _getScheduleFromAvailableTime(doctor.availableTime, day);
    }

    return null;
  }

  static bool isDoctorAvailableOnDay(DoctorEntity doctor, DateTime date) {
    final schedule = getScheduleForDate(doctor, date);
    return schedule?.enabled ?? false;
  }

  static bool isDateSelectableStatic(DoctorEntity doctor, DateTime date) {
    final today = _dateOnly(DateTime.now());
    final selected = _dateOnly(date);
    if (selected.isBefore(today)) {
      return false;
    }
    return isDoctorAvailableOnDay(doctor, selected);
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

    final startParts = schedule.startTime.split(':');
    final endParts = schedule.endTime.split(':');

    if (startParts.length != 2 || endParts.length != 2) {
      return [];
    }

    final startHour = int.tryParse(startParts[0]);
    final startMinute = int.tryParse(startParts[1]);
    final endHour = int.tryParse(endParts[0]);
    final endMinute = int.tryParse(endParts[1]);

    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return [];
    }

    int currentMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
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
          emit(
            state.copyWith(
              doctor: liveDoctor,
              selectedDate: _getFirstAvailableDateStatic(liveDoctor),
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
        TimeOfDay? updatedSelectedTime = state.selectedTime;
        if (updatedSelectedTime != null &&
            data.contains(timeKey(updatedSelectedTime))) {
          updatedSelectedTime = null;
        }

        emit(
          state.copyWith(
            bookedSlots: data,
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
