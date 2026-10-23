import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> allNotifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.allNotifications = const [],
    this.errorMessage,
  });

  bool get isLoading => status == NotificationsStatus.loading;
  bool get hasError => status == NotificationsStatus.error;
  bool get isError => status == NotificationsStatus.error;
  bool get isEmpty =>
      status == NotificationsStatus.loaded && allNotifications.isEmpty;

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  List<NotificationEntity> get todayNotifications {
    final now = DateTime.now();
    return allNotifications.where((n) {
      return n.timestamp.year == now.year &&
          n.timestamp.month == now.month &&
          n.timestamp.day == now.day;
    }).toList();
  }

  List<NotificationEntity> get yesterdayNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return allNotifications.where((n) {
      return n.timestamp.year == yesterday.year &&
          n.timestamp.month == yesterday.month &&
          n.timestamp.day == yesterday.day;
    }).toList();
  }

  List<NotificationEntity> get olderNotifications {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return allNotifications.where((n) {
      final isToday = n.timestamp.year == now.year &&
          n.timestamp.month == now.month &&
          n.timestamp.day == now.day;
      final isYesterday = n.timestamp.year == yesterday.year &&
          n.timestamp.month == yesterday.month &&
          n.timestamp.day == yesterday.day;
      return !isToday && !isYesterday;
    }).toList();
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? allNotifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      allNotifications: allNotifications ?? this.allNotifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allNotifications, errorMessage];
}
