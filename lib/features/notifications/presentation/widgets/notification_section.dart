import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationSection extends StatelessWidget {
  final String title;
  final List<NotificationEntity> notifications;
  final VoidCallback onMarkAllAsRead;
  final ValueChanged<NotificationEntity> onNotificationTap;

  const NotificationSection({
    super.key,
    required this.title,
    required this.notifications,
    required this.onMarkAllAsRead,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasUnread = notifications.any((n) => !n.isRead);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.inter12W500.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray500,
                  letterSpacing: 0.5,
                ),
              ),
              if (hasUnread)
                InkWell(
                  onTap: onMarkAllAsRead,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Text(
                      LocaleKeys.markAllAsRead.tr(),
                      style: AppTextStyles.inter12W500.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTeal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFF3F4F6),
          ),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationItem(
              notification: notification,
              onTap: () => onNotificationTap(notification),
            );
          },
        ),
      ],
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  Color get _iconBgColor {
    switch (notification.type) {
      case NotificationType.appointmentSuccess:
        return const Color(0xFFE8F7F0);
      case NotificationType.appointmentCancelled:
        return const Color(0xFFFDE8E8);
      case NotificationType.scheduleChanged:
        return const Color(0xFFF0F4F8);
      default:
        return const Color(0xFFE6F7F5);
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.appointmentSuccess:
        return const Color(0xFF10B981);
      case NotificationType.appointmentCancelled:
        return const Color(0xFFEF4444);
      case NotificationType.scheduleChanged:
        return const Color(0xFF4B5563);
      default:
        return AppColors.darkTeal;
    }
  }

  IconData get _iconData {
    switch (notification.type) {
      case NotificationType.appointmentSuccess:
        return Icons.event_available_rounded;
      case NotificationType.appointmentCancelled:
        return Icons.event_busy_rounded;
      case NotificationType.scheduleChanged:
        return Icons.event_repeat_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tileBg = notification.isRead
        ? AppColors.white
        : const Color(0xFFF8F9FB);

    return Material(
      color: tileBg,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.gray100,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _iconData,
                    size: 24.r,
                    color: _iconColor,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.inter16W500.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTeal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          notification.timeAgo,
                          style: AppTextStyles.inter12W400.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      notification.description,
                      style: AppTextStyles.inter14W400.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.gray500,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
