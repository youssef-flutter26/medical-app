import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medical_app/features/appointment/domain/usecases/book_appointment.dart';
import 'package:medical_app/features/appointment/domain/usecases/get_booked_slots.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_cubit.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_state.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class _TestFailure extends Failure {
  _TestFailure(super.message);
}

class _FakeAppointmentRepository implements AppointmentRepository {
  Set<String> bookedSlots = {};
  bool shouldFailBooking = false;
  String? lastBookedDoctorId;
  String? lastBookedTime;
  String? lastPatientId;

  @override
  Future<Result<Set<String>>> getBookedSlots({
    required String doctorId,
    required String dateKey,
  }) async {
    return SuccessAPI(bookedSlots);
  }

  @override
  Future<Result<void>> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
    String? doctorSpecialty,
    String? doctorAddress,
    String? doctorImagePath,
  }) async {
    if (shouldFailBooking) {
      return ErrorAPI(_TestFailure('Booking failed on server'));
    }
    lastBookedDoctorId = doctorId;
    lastBookedTime = time;
    lastPatientId = patientId;
    bookedSlots.add(time);
    return const SuccessAPI(null);
  }

  @override
  Stream<List<AppointmentEntity>> streamUserAppointments(String patientId) {
    return Stream.value([]);
  }

  @override
  Future<Result<List<AppointmentEntity>>> getUserAppointments(String patientId) async {
    return const SuccessAPI([]);
  }

  @override
  Future<Result<void>> cancelAppointment(String appointmentId) async {
    return const SuccessAPI(null);
  }

  @override
  Future<Result<void>> rescheduleAppointment({
    required String appointmentId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
  }) async {
    bookedSlots.add(time);
    return const SuccessAPI(null);
  }
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'patient_123';
}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  _FakeUser? user = _FakeUser();

  @override
  User? get currentUser => user;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAppointmentRepository fakeRepository;
  late BookAppointment bookAppointment;
  late GetBookedSlots getBookedSlots;
  late _FakeFirebaseAuth fakeAuth;

  const testDoctor = DoctorEntity(
    id: 'doc_123',
    name: 'Dr. James Robinson',
    specialty: 'Orthopedic Surgery',
    categoryId: 'cat_ortho',
    categoryName: 'Orthopedics',
    address: 'Elite Ortho Clinic, USA',
    rating: 4.8,
    reviewsCount: 120,
    availableTime: '',
    imagePath: 'assets/images/Doctor_1.png',
    schedule: [
      DoctorSchedule(
        day: 'monday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'tuesday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'wednesday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'thursday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'friday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'saturday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'sunday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
    ],
  );

  setUp(() {
    fakeRepository = _FakeAppointmentRepository();
    bookAppointment = BookAppointment(fakeRepository);
    getBookedSlots = GetBookedSlots(fakeRepository);
    fakeAuth = _FakeFirebaseAuth();
  });

  group('AppointmentCubit tests', () {
    test('initial state calculates first available date and loads slots', () async {
      final cubit = AppointmentCubit(
        doctor: testDoctor,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      expect(cubit.state.doctor, testDoctor);
      expect(cubit.state.selectedDate, isNotNull);
      expect(cubit.state.selectedTime, isNull);
      expect(cubit.state.bookingStatus, BookingStatus.initial);

      // Wait for initial loadBookedSlots
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isLoadingSlots, false);

      cubit.close();
    });

    test('selectTime updates selectedTime in state', () {
      final cubit = AppointmentCubit(
        doctor: testDoctor,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      const time = TimeOfDay(hour: 10, minute: 0);
      cubit.selectTime(time);

      expect(cubit.state.selectedTime, time);
      cubit.close();
    });

    test('bookAppointment fails if no time is selected', () async {
      final cubit = AppointmentCubit(
        doctor: testDoctor,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      await cubit.bookAppointment();

      expect(cubit.state.bookingStatus, BookingStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);
      cubit.close();
    });

    test('bookAppointment succeeds when time is selected and user is authenticated', () async {
      final cubit = AppointmentCubit(
        doctor: testDoctor,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      // Choose a future time slot: e.g. select a future date
      final futureDate = DateTime.now().add(const Duration(days: 5));
      await cubit.selectDate(futureDate);

      const time = TimeOfDay(hour: 14, minute: 0);
      cubit.selectTime(time);

      await cubit.bookAppointment();

      expect(cubit.state.bookingStatus, BookingStatus.success);
      expect(fakeRepository.lastBookedDoctorId, 'doc_123');
      expect(fakeRepository.lastPatientId, 'patient_123');
      expect(fakeRepository.lastBookedTime, '14:00');
      cubit.close();
    });

    test('bookAppointment handles failure from repository', () async {
      fakeRepository.shouldFailBooking = true;

      final cubit = AppointmentCubit(
        doctor: testDoctor,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      final futureDate = DateTime.now().add(const Duration(days: 5));
      await cubit.selectDate(futureDate);

      const time = TimeOfDay(hour: 11, minute: 30);
      cubit.selectTime(time);

      await cubit.bookAppointment();

      expect(cubit.state.bookingStatus, BookingStatus.failure);
      expect(cubit.state.errorMessage, 'Booking failed on server');
      cubit.close();
    });

    test('doctor with NO schedule has no availability and no selectable dates or slots', () {
      const doctorNoSchedule = DoctorEntity(
        id: 'doc_empty',
        name: 'Dr. No Schedule',
        specialty: 'General',
        categoryId: 'cat_gen',
        categoryName: 'General',
        address: 'Clinic',
        rating: 4.5,
        reviewsCount: 10,
        availableTime: '',
        imagePath: '',
        schedule: [],
      );

      final cubit = AppointmentCubit(
        doctor: doctorNoSchedule,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      expect(cubit.hasDoctorAvailability, isFalse);
      expect(cubit.isDateSelectable(DateTime.now().add(const Duration(days: 1))), isFalse);
      expect(cubit.getAvailableTimeSlotsForSelectedDate(), isEmpty);
      cubit.close();
    });

    test('doctor with specific days enabled only allows enabled days', () {
      const doctorSpecific = DoctorEntity(
        id: 'doc_mon',
        name: 'Dr. Monday Only',
        specialty: 'General',
        categoryId: 'cat_gen',
        categoryName: 'General',
        address: 'Clinic',
        rating: 4.5,
        reviewsCount: 10,
        availableTime: '',
        imagePath: '',
        schedule: [
          DoctorSchedule(
            day: 'monday',
            enabled: true,
            startTime: '10:00',
            endTime: '12:00',
          ),
          DoctorSchedule(
            day: 'tuesday',
            enabled: false,
            startTime: '10:00',
            endTime: '12:00',
          ),
        ],
      );

      final cubit = AppointmentCubit(
        doctor: doctorSpecific,
        bookAppointment: bookAppointment,
        getBookedSlots: getBookedSlots,
        auth: fakeAuth,
      );

      expect(cubit.hasDoctorAvailability, isTrue);

      // Find next Monday and next Tuesday in the future
      DateTime nextMonday = DateTime.now().add(const Duration(days: 1));
      while (nextMonday.weekday != DateTime.monday) {
        nextMonday = nextMonday.add(const Duration(days: 1));
      }
      DateTime nextTuesday = DateTime.now().add(const Duration(days: 1));
      while (nextTuesday.weekday != DateTime.tuesday) {
        nextTuesday = nextTuesday.add(const Duration(days: 1));
      }

      expect(cubit.isDateSelectable(nextMonday), isTrue);
      expect(cubit.isDateSelectable(nextTuesday), isFalse);

      cubit.selectDate(nextMonday);
      final slots = cubit.getAvailableTimeSlotsForSelectedDate();
      expect(slots.length, 4); // 10:00, 10:30, 11:00, 11:30
      expect(slots.first, const TimeOfDay(hour: 10, minute: 0));
      expect(slots.last, const TimeOfDay(hour: 11, minute: 30));

      cubit.close();
    });
  });
}
