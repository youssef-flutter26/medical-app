import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/presention/pages/my_bookings_page.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_empty_state.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_tab_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssetLoader extends AssetLoader {
  const _FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "myBookings": "My Bookings",
      "upcoming": "Upcoming",
      "completed": "Completed",
      "canceled": "Canceled",
      "cancel": "Cancel",
      "reschedule": "Reschedule",
      "reBook": "Re-Book",
      "addReview": "Add Review",
      "noBookingsFound": "No bookings found",
      "noUpcomingBookings": "No upcoming bookings",
      "noCompletedBookings": "No completed bookings",
      "noCanceledBookings": "No canceled bookings",
      "cancelBookingConfirmation": "Are you sure you want to cancel this booking?",
      "bookingCanceledSuccessfully": "Booking canceled successfully",
      "rescheduleAppointment": "Reschedule Appointment",
      "bookAppointment": "Book Appointment",
      "selectDate": "Select Date",
      "selectHour": "Select Hour",
      "confirm": "Confirm",
      "bookingSummary": "Booking Summary",
      "doctorNoAvailability": "This doctor has no available appointments currently.",
      "doctorNotFound": "Doctor information could not be found.",
      "back": "Back",
      "ok": "OK",
    };
  }
}

Widget createMyBookingsTestWidget({
  List<AppointmentEntity>? initialAppointments,
  BookingTab initialTab = BookingTab.upcoming,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeAssetLoader(),
    child: AppScreenUtilScope(
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: MyBookingsPage(
              initialAppointments: initialAppointments,
              initialTab: initialTab,
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  final testUserAppointments = [
    AppointmentEntity(
      id: 'app_1',
      doctorId: 'doc_1',
      doctorName: 'Dr. Sarah Connor',
      doctorSpecialty: 'Cardiology',
      doctorAddress: 'Cardio Clinic, NY',
      doctorImagePath: '',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      dateKey: '2026-10-10',
      time: '10:00 AM',
      status: 'booked',
      patientId: 'user_123',
    ),
    AppointmentEntity(
      id: 'app_2',
      doctorId: 'doc_2',
      doctorName: 'Dr. John Watson',
      doctorSpecialty: 'General Medicine',
      doctorAddress: 'Baker St Clinic',
      doctorImagePath: '',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      dateKey: '2026-10-03',
      time: '11:00 AM',
      status: 'completed',
      patientId: 'user_123',
    ),
    AppointmentEntity(
      id: 'app_3',
      doctorId: 'doc_3',
      doctorName: 'Dr. Gregory House',
      doctorSpecialty: 'Diagnostics',
      doctorAddress: 'Princeton Hospital',
      doctorImagePath: '',
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
      dateKey: '2026-09-28',
      time: '02:00 PM',
      status: 'canceled',
      patientId: 'user_123',
    ),
  ];

  group('MyBookingsPage widget tests', () {
    testWidgets('shows empty state when user has no bookings', (tester) async {
      await tester.pumpWidget(createMyBookingsTestWidget(
        initialAppointments: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Canceled'), findsOneWidget);

      // Empty state on Upcoming
      expect(find.byType(BookingEmptyState), findsOneWidget);
      expect(find.text('No upcoming bookings'), findsOneWidget);

      // Switch to Completed
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.byType(BookingEmptyState), findsOneWidget);
      expect(find.text('No completed bookings'), findsOneWidget);

      // Switch to Canceled
      await tester.tap(find.text('Canceled'));
      await tester.pumpAndSettle();
      expect(find.byType(BookingEmptyState), findsOneWidget);
      expect(find.text('No canceled bookings'), findsOneWidget);
    });

    testWidgets('displays user bookings and filters by tab', (tester) async {
      await tester.pumpWidget(createMyBookingsTestWidget(
        initialAppointments: testUserAppointments,
      ));
      await tester.pumpAndSettle();

      // Upcoming tab displays Dr. Sarah Connor
      expect(find.text('Dr. Sarah Connor'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);
      expect(find.text('Dr. John Watson'), findsNothing);
      expect(find.text('Dr. Gregory House'), findsNothing);

      // Switch to Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Dr. John Watson'), findsOneWidget);
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('Re-Book'), findsOneWidget);
      expect(find.text('Add Review'), findsOneWidget);
      expect(find.text('Dr. Sarah Connor'), findsNothing);

      // Switch to Canceled tab
      await tester.tap(find.text('Canceled'));
      await tester.pumpAndSettle();
      expect(find.text('Dr. Gregory House'), findsOneWidget);
      expect(find.text('Diagnostics'), findsOneWidget);
      expect(find.text('Re-Book'), findsOneWidget);
      expect(find.text('Dr. Sarah Connor'), findsNothing);
    });

    testWidgets('cancels an upcoming booking and moves it to Canceled tab', (
      tester,
    ) async {
      await tester.pumpWidget(createMyBookingsTestWidget(
        initialAppointments: testUserAppointments,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Connor'), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Confirmation dialog shows
      expect(
        find.text('Are you sure you want to cancel this booking?'),
        findsOneWidget,
      );

      // Tap OK in dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Dr. Sarah Connor is no longer in Upcoming
      expect(find.text('Dr. Sarah Connor'), findsNothing);

      // Switch to Canceled tab
      await tester.tap(find.text('Canceled'));
      await tester.pumpAndSettle();

      // Dr. Sarah Connor is now in Canceled tab
      expect(find.text('Dr. Sarah Connor'), findsOneWidget);
    });

    testWidgets('tapping Reschedule opens BookAppointmentPage without red screen', (
      tester,
    ) async {
      await tester.pumpWidget(createMyBookingsTestWidget(
        initialAppointments: testUserAppointments,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Reschedule'), findsOneWidget);

      await tester.tap(find.text('Reschedule'));
      await tester.pump();

      // Verify no assertion error or exception was thrown
      expect(tester.takeException(), isNull);
    });
  });
}
