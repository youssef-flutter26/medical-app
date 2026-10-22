import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:medical_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:medical_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:medical_app/features/notifications/presentation/widgets/notification_section.dart';
import 'package:medical_app/features/notifications/presentation/widgets/notifications_app_bar.dart';
import 'package:medical_app/features/notifications/presentation/widgets/notifications_empty_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsTestAssetLoader extends AssetLoader {
  const NotificationsTestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "notification": "Notification",
      "newNotificationsCount": "{} New",
      "today": "TODAY",
      "yesterday": "YESTERDAY",
      "older": "OLDER",
      "markAllAsRead": "Mark all as read",
      "appointmentSuccess": "Appointment Success",
      "appointmentCancelled": "Appointment Cancelled",
      "scheduledChanged": "Scheduled Changed",
      "scheduleChanged": "Schedule Changed",
      "noNotificationsYet": "No Notifications Yet",
      "noNotificationsDescription": "You don't have any notifications right now.",
    };
  }
}

class FakeNotificationRepository implements NotificationRepository {
  final StreamController<List<NotificationEntity>> _controller =
      StreamController<List<NotificationEntity>>.broadcast();
  List<NotificationEntity> notifications = [];

  @override
  Stream<List<NotificationEntity>> getNotificationsStream(String userId) {
    return _controller.stream;
  }

  void emit(List<NotificationEntity> list) {
    notifications = list;
    _controller.add(list);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    notifications = notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _controller.add(notifications);
  }

  @override
  Future<void> markSectionAsRead(
    String userId,
    List<String> notificationIds,
  ) async {
    final idSet = notificationIds.toSet();
    notifications = notifications.map((n) {
      if (idSet.contains(n.id)) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _controller.add(notifications);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    _controller.add(notifications);
  }

  @override
  Future<void> refresh(String userId) async {
    _controller.add(notifications);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('NotificationsCubit unit tests', () {
    late FakeNotificationRepository fakeRepo;
    late NotificationsCubit cubit;

    late DateTime now;
    late NotificationEntity notifTodaySuccess;
    late NotificationEntity notifTodayCancelled;
    late NotificationEntity notifYesterdaySuccess;

    setUp(() {
      now = DateTime.now();
      notifTodaySuccess = NotificationEntity(
        id: 'notif_1',
        title: 'Appointment Success',
        description:
            'You have successfully booked your appointment with Dr. Emily Walker.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: true,
        type: NotificationType.appointmentSuccess,
      );

      notifTodayCancelled = NotificationEntity(
        id: 'notif_2',
        title: 'Appointment Cancelled',
        description:
            'You have successfully cancelled your appointment with Dr. David Patel.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: false,
        type: NotificationType.appointmentCancelled,
      );

      notifYesterdaySuccess = NotificationEntity(
        id: 'notif_3',
        title: 'Appointment success',
        description:
            'You have successfully booked your appointment with Dr. David Patel.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.appointmentSuccess,
      );

      fakeRepo = FakeNotificationRepository();
      cubit = NotificationsCubit(
        notificationRepository: fakeRepo,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has empty notifications and 0 unread', () {
      expect(cubit.state.allNotifications, isEmpty);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.isEmpty, isFalse);
    });

    test('streaming notifications groups by date and computes unread count', () async {
      cubit.init();
      fakeRepo.emit([notifTodaySuccess, notifTodayCancelled, notifYesterdaySuccess]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.allNotifications.length, 3);
      expect(cubit.state.unreadCount, 1); // exactly 1 unread (matches '1 New' in reference design)
      expect(cubit.state.todayNotifications.length, 2);
      expect(cubit.state.yesterdayNotifications.length, 1);
    });

    test('markAsRead marks notification as read and updates unreadCount', () async {
      cubit.init();
      fakeRepo.emit([notifTodayCancelled]);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.unreadCount, 1);

      await cubit.markAsRead('notif_2');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.allNotifications.first.isRead, isTrue);
    });

    test('markSectionAsRead marks all notifications in section as read', () async {
      final unread1 = notifTodaySuccess.copyWith(isRead: false);
      final unread2 = notifTodayCancelled.copyWith(isRead: false);

      cubit.init();
      fakeRepo.emit([unread1, unread2]);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.unreadCount, 2);

      await cubit.markSectionAsRead(['notif_1', 'notif_2']);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.unreadCount, 0);
    });
  });

  group('Notifications UI Widget tests', () {
    Widget buildTestWidget(Widget child) {
      return EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const NotificationsTestAssetLoader(),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: Builder(
            builder: (context) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: Scaffold(body: child),
            ),
          ),
        ),
      );
    }

    testWidgets('NotificationsAppBar renders title and 1 New pill badge',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationsAppBar(unreadCount: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('1 New'), findsOneWidget);
    });

    testWidgets('NotificationsEmptyState renders when empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(const NotificationsEmptyState()));
      await tester.pumpAndSettle();

      expect(find.text('No Notifications Yet'), findsOneWidget);
      expect(find.text("You don't have any notifications right now."),
          findsOneWidget);
    });

    testWidgets('NotificationItem visual differentiation between read and unread',
        (tester) async {
      final unreadItem = NotificationEntity(
        id: '2',
        title: 'Appointment Cancelled',
        description: 'You have successfully cancelled your appointment with Dr. David Patel.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.appointmentCancelled,
      );

      await tester.pumpWidget(buildTestWidget(
        NotificationItem(
          notification: unreadItem,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Appointment Cancelled'), findsOneWidget);
      expect(find.text('2h'), findsOneWidget);
      expect(
        find.text(
            'You have successfully cancelled your appointment with Dr. David Patel.'),
        findsOneWidget,
      );
    });

    testWidgets('NotificationSection renders section title and Mark all as read button',
        (tester) async {
      bool markAllTapped = false;
      final unreadItem = NotificationEntity(
        id: '2',
        title: 'Appointment Cancelled',
        description: 'You have successfully cancelled your appointment.',
        timestamp: DateTime.now(),
        isRead: false,
        type: NotificationType.appointmentCancelled,
      );

      await tester.pumpWidget(buildTestWidget(
        NotificationSection(
          title: 'TODAY',
          notifications: [unreadItem],
          onMarkAllAsRead: () => markAllTapped = true,
          onNotificationTap: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);

      await tester.tap(find.text('Mark all as read'));
      expect(markAllTapped, isTrue);
    });
  });
}
