import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/failure.dart';
import 'package:medical_app/core/error/result.dart';
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
    availableTime: '09:00 - 17:00',
    imagePath: 'assets/images/Doctor_1.png',
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
  });
}
