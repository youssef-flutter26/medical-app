import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medical_app/features/appointment/domain/usecases/book_appointment.dart';
import 'package:medical_app/features/appointment/domain/usecases/get_booked_slots.dart';
import 'package:medical_app/features/appointment/presention/cubit/appointment_cubit.dart';
import 'package:medical_app/features/appointment/presention/pages/book_appointment_page.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class _FakeBookingRepository implements AppointmentRepository {
  Set<String> bookedSlots = {};
  bool bookedCalled = false;

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
    bookedCalled = true;
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

class _FakeBookingUser extends Fake implements User {
  @override
  String get uid => 'user_123';
}

class _FakeBookingAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => _FakeBookingUser();
}

class _FakeBookingAssetLoader extends AssetLoader {
  const _FakeBookingAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "bookAppointment": "Book Appointment",
      "selectDate": "Select Date",
      "selectHour": "Select Hour",
      "confirm": "Confirm",
      "noAvailableSlots": "No available appointments for this day.",
      "booked": "Booked",
      "passed": "Passed",
      "done": "Done",
      "congratulations": "Congratulations",
      "editYourAppointment": "Edit your appointment",
      "pleaseSelectTime": "Please select an appointment time.",
      "bookingSuccessful": "Booking successful",
      "bookingFailed": "Booking failed",
      "bookingSummary": "Booking Summary",
      "appointmentDate": "Appointment Date",
      "appointmentTime": "Appointment Time",
      "readyToConfirm": "Ready to confirm",
      "pleaseSelectSlotToProceed": "Please select a time slot",
      "doctorNoAvailability": "This doctor has no available appointments currently.",
    };
  }
}

Widget createBookingTestWidget({
  required DoctorEntity doctor,
  required AppointmentCubit cubit,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeBookingAssetLoader(),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: BookAppointmentPage(
              doctor: doctor,
              cubit: cubit,
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testDoctor = DoctorEntity(
    id: 'doc_1',
    name: 'Dr. James Robinson',
    specialty: 'Orthopedic Surgery',
    categoryId: 'cat_ortho',
    categoryName: 'Orthopedics',
    address: 'Elite Ortho Clinic, USA',
    rating: 4.8,
    reviewsCount: 120,
    availableTime: '09:00 - 17:00',
    imagePath: '',
    schedule: [
      DoctorSchedule(
        day: 'sunday',
        enabled: true,
        startTime: '09:00',
        endTime: '17:00',
      ),
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
    ],
  );

  testWidgets('renders doctor summary, date selector, hour selector, and confirm button',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = _FakeBookingRepository();
    final cubit = AppointmentCubit(
      doctor: testDoctor,
      bookAppointment: BookAppointment(fakeRepo),
      getBookedSlots: GetBookedSlots(fakeRepo),
      auth: _FakeBookingAuth(),
    );

    await tester.pumpWidget(createBookingTestWidget(
      doctor: testDoctor,
      cubit: cubit,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Book Appointment'), findsOneWidget);
    expect(find.text('Dr. James Robinson'), findsOneWidget);
    expect(find.text('Orthopedic Surgery'), findsOneWidget);
    expect(find.text('Elite Ortho Clinic, USA'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Select Hour'), findsOneWidget);
    expect(find.text('Booking Summary'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    cubit.close();
  });

  testWidgets('selecting a slot enables confirm and tapping confirm books appointment',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = _FakeBookingRepository();
    final cubit = AppointmentCubit(
      doctor: testDoctor,
      bookAppointment: BookAppointment(fakeRepo),
      getBookedSlots: GetBookedSlots(fakeRepo),
      auth: _FakeBookingAuth(),
    );

    // Pick a future date to avoid past slot validation
    final futureDate = DateTime.now().add(const Duration(days: 7));
    await cubit.selectDate(futureDate);

    await tester.pumpWidget(createBookingTestWidget(
      doctor: testDoctor,
      cubit: cubit,
    ));
    await tester.pumpAndSettle();

    // Select 10:00 AM slot
    final slotFinder = find.text('10:00 AM');
    expect(slotFinder, findsOneWidget);
    await tester.ensureVisible(slotFinder);
    await tester.tap(slotFinder);
    await tester.pumpAndSettle();

    expect(cubit.state.selectedTime, const TimeOfDay(hour: 10, minute: 0));

    // Tap Confirm button
    final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(fakeRepo.bookedCalled, isTrue);
    expect(find.text('Congratulations'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    cubit.close();
  });
}
