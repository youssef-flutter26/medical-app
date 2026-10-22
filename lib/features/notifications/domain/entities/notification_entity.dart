import 'package:equatable/equatable.dart';

enum NotificationType {
  appointmentSuccess,
  appointmentCancelled,
  scheduleChanged,
  general,
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? appointmentId;
  final String? doctorId;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.general,
    this.appointmentId,
    this.doctorId,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}m';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    String? appointmentId,
    String? doctorId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        timestamp,
        isRead,
        type,
        appointmentId,
        doctorId,
      ];
}
