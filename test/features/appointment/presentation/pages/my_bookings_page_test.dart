import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/presention/pages/my_bookings_page.dart';
import 'package:medical_app/features/appointment/presention/widgets/booking_card.dart';
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

  group('MyBookingsPage widget tests', () {
    testWidgets('renders title, tabs, and initial upcoming bookings from design', (
      tester,
    ) async {
      await tester.pumpWidget(createMyBookingsTestWidget());
      await tester.pumpAndSettle();

      // Title
      expect(find.text('My Bookings'), findsOneWidget);

      // Tabs
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Canceled'), findsOneWidget);

      // Cards from design
      expect(find.byType(BookingCard), findsAtLeastNWidgets(2));
      expect(find.text('Dr. James Robinson'), findsOneWidget);
      expect(find.text('Orthopedic Surgery'), findsWidgets);
      expect(find.text('Elite Ortho Clinic, USA'), findsWidgets);
      expect(find.text('Dr. Daniel Lee'), findsOneWidget);
      expect(find.text('Gastroenterologist'), findsOneWidget);
      expect(find.text('Digestive Institute, USA'), findsOneWidget);

      // Upcoming action buttons
      expect(find.text('Cancel'), findsWidgets);
      expect(find.text('Reschedule'), findsWidgets);
    });

    testWidgets('switches to Completed tab and displays completed bookings', (
      tester,
    ) async {
      await tester.pumpWidget(createMyBookingsTestWidget());
      await tester.pumpAndSettle();

      // Tap Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Completed cards from design
      expect(find.text('Dr. Sarah Johnson'), findsOneWidget);
      expect(find.text('Gynecologist'), findsOneWidget);
      expect(find.text("Women's Health Clinic"), findsOneWidget);

      expect(find.text('Dr. Michael Chang'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('HeartCare Center, USA'), findsOneWidget);

      // Completed action buttons
      expect(find.text('Re-Book'), findsWidgets);
      expect(find.text('Add Review'), findsWidgets);
      expect(find.text('Reschedule'), findsNothing);
    });

    testWidgets('switches to Canceled tab and displays canceled bookings', (
      tester,
    ) async {
      await tester.pumpWidget(createMyBookingsTestWidget());
      await tester.pumpAndSettle();

      // Tap Canceled tab
      await tester.tap(find.text('Canceled'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Emily Watson'), findsOneWidget);
      expect(find.text('Neurologist'), findsOneWidget);
      expect(find.text('Re-Book'), findsWidgets);
    });

    testWidgets('cancels an upcoming booking and moves it to Canceled tab', (
      tester,
    ) async {
      await tester.pumpWidget(createMyBookingsTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dr. James Robinson'), findsOneWidget);

      // Tap first Cancel button
      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();

      // Confirmation dialog shows
      expect(
        find.text('Are you sure you want to cancel this booking?'),
        findsOneWidget,
      );

      // Tap OK in dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Dr. James Robinson should no longer be in Upcoming tab
      expect(find.text('Dr. James Robinson'), findsNothing);

      // Switch to Canceled tab
      await tester.tap(find.text('Canceled'));
      await tester.pumpAndSettle();

      // Dr. James Robinson is now in Canceled tab
      expect(find.text('Dr. James Robinson'), findsOneWidget);
    });
  });
}
