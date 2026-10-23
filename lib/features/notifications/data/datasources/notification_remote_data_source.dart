import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/repositories/appointment_repository.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationEntity>> streamNotifications(String userId);
  Future<void> markAsReadInRemote(String userId, String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final AppointmentRepository _appointmentRepository;
  final FirebaseFirestore? _firestore;

  NotificationRemoteDataSourceImpl({
    required AppointmentRepository appointmentRepository,
    FirebaseFirestore? firestore,
  })  : _appointmentRepository = appointmentRepository,
        _firestore = firestore;

  @override
  Stream<List<NotificationEntity>> streamNotifications(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const <NotificationEntity>[]);
    }

    // 1. Stream from real appointments
    final appointmentsStream =
        _appointmentRepository.streamUserAppointments(userId);

    // 2. Stream from Firestore users/{userId}/notifications if firestore exists
    Stream<List<NotificationEntity>> firestoreNotificationsStream;
    final firestore = _firestore;
    if (firestore != null) {
      firestoreNotificationsStream = firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final typeStr = data['type'] as String? ?? 'general';
          NotificationType type;
          switch (typeStr) {
            case 'appointmentSuccess':
              type = NotificationType.appointmentSuccess;
              break;
            case 'appointmentCancelled':
              type = NotificationType.appointmentCancelled;
              break;
            case 'scheduleChanged':
              type = NotificationType.scheduleChanged;
              break;
            default:
              type = NotificationType.general;
          }

          final timestamp = (data['timestamp'] is Timestamp)
              ? (data['timestamp'] as Timestamp).toDate()
              : (data['timestamp'] != null
                  ? DateTime.tryParse(data['timestamp'].toString()) ??
                      DateTime.now()
                  : DateTime.now());

          return NotificationEntity(
            id: doc.id,
            title: data['title'] as String? ?? 'Notification',
            description: data['description'] as String? ?? '',
            timestamp: timestamp,
            isRead: data['isRead'] as bool? ?? false,
            type: type,
            appointmentId: data['appointmentId'] as String?,
            doctorId: data['doctorId'] as String?,
          );
        }).toList();
      }).handleError((_) => const <NotificationEntity>[]);
    } else {
      firestoreNotificationsStream = Stream.value(const <NotificationEntity>[]);
    }

    // Combine both streams
    final controller = StreamController<List<NotificationEntity>>.broadcast();

    List<NotificationEntity> lastAppointments = [];
    List<NotificationEntity> lastCustom = [];

    void emitMerged() {
      if (controller.isClosed) return;
      final mergedMap = <String, NotificationEntity>{};

      for (final n in lastCustom) {
        mergedMap[n.id] = n;
      }
      for (final n in lastAppointments) {
        mergedMap[n.id] = n;
      }

      final list = mergedMap.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      controller.add(list);
    }

    StreamSubscription? sub1;
    StreamSubscription? sub2;

    controller.onListen = () {
      sub1 = appointmentsStream.listen(
        (appointments) {
          lastAppointments = _mapAppointmentsToNotifications(appointments);
          emitMerged();
        },
        onError: (e) {
          if (!controller.isClosed) {
            controller.addError(e);
          }
        },
      );

      sub2 = firestoreNotificationsStream.listen(
        (customList) {
          lastCustom = customList;
          emitMerged();
        },
        onError: (e) {
          // If firestore notifications sub fails, keep appointments
        },
      );
    };

    controller.onCancel = () {
      sub1?.cancel();
      sub2?.cancel();
    };

    return controller.stream;
  }

  List<NotificationEntity> _mapAppointmentsToNotifications(
    List<AppointmentEntity> appointments,
  ) {
    final notifications = <NotificationEntity>[];

    for (final appt in appointments) {
      final apptId = appt.id ?? '${appt.doctorId}_${appt.dateKey}_${appt.time}';
      final doctorName = appt.doctorName.isNotEmpty ? appt.doctorName : 'Doctor';

      final timestamp = appt.createdAt ?? appt.dateTime;
      final status = appt.status.toLowerCase();

      if (status == 'cancelled' || status == 'canceled') {
        notifications.add(
          NotificationEntity(
            id: 'notif_cancel_$apptId',
            title: 'Appointment Cancelled',
            description:
                'You have successfully cancelled your appointment with $doctorName.',
            timestamp: timestamp,
            isRead: false,
            type: NotificationType.appointmentCancelled,
            appointmentId: appt.id ?? apptId,
            doctorId: appt.doctorId,
          ),
        );
      } else if (status == 'rescheduled') {
        notifications.add(
          NotificationEntity(
            id: 'notif_resched_$apptId',
            title: 'Schedule Changed',
            description:
                'You have successfully changed your appointment with $doctorName.',
            timestamp: timestamp,
            isRead: false,
            type: NotificationType.scheduleChanged,
            appointmentId: appt.id ?? apptId,
            doctorId: appt.doctorId,
          ),
        );
      } else {
        // Booked or upcoming or completed
        notifications.add(
          NotificationEntity(
            id: 'notif_success_$apptId',
            title: 'Appointment Success',
            description:
                'You have successfully booked your appointment with $doctorName.',
            timestamp: timestamp,
            isRead: false,
            type: NotificationType.appointmentSuccess,
            appointmentId: appt.id ?? apptId,
            doctorId: appt.doctorId,
          ),
        );
      }
    }

    return notifications;
  }

  @override
  Future<void> markAsReadInRemote(String userId, String notificationId) async {
    if (notificationId.startsWith('notif_')) {
      // Derived from appointment - read status is tracked locally and persisted in local data source
      return;
    }
    final firestore = _firestore;
    if (firestore == null || userId.isEmpty) return;
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({'isRead': true});
      }
    } catch (_) {}
  }
}
