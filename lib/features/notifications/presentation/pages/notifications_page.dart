import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/appointment/domain/entities/appointment_entity.dart';
import 'package:medical_app/features/appointment/domain/repositories/appointment_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_section.dart';
import '../widgets/notifications_app_bar.dart';
import '../widgets/notifications_empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..init(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  Future<void> _handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) async {
    final cubit = context.read<NotificationsCubit>();
    await cubit.markAsRead(notification.id);

    final appointmentId = notification.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) {
      return;
    }

    final auth = getIt.isRegistered<FirebaseAuth>()
        ? getIt<FirebaseAuth>()
        : null;
    final userId = auth?.currentUser?.uid ??
        (() {
          try {
            return FirebaseAuth.instance.currentUser?.uid;
          } catch (_) {
            return null;
          }
        })();

    if (userId == null || userId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please log in to view appointment details.'),
            backgroundColor: AppColors.darkTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
      return;
    }

    final repo = getIt.isRegistered<AppointmentRepository>()
        ? getIt<AppointmentRepository>()
        : null;

    if (repo == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Appointment service is currently unavailable.'),
            backgroundColor: AppColors.darkTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
      return;
    }

    AppointmentEntity? targetAppointment;
    try {
      final result = await repo.getUserAppointments(userId);
      if (result is SuccessAPI<List<AppointmentEntity>>) {
        final list = result.data;
        for (final appt in list) {
          if (appt.id == appointmentId ||
              '${appt.doctorId}_${appt.dateKey}_${appt.time}' == appointmentId) {
            targetAppointment = appt;
            break;
          }
        }
      }
    } catch (_) {}

    if (!context.mounted) return;

    if (targetAppointment != null) {
      Navigator.pushNamed(
        context,
        Routes.appointment,
        arguments: targetAppointment,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Appointment details are no longer available.',
          ),
          backgroundColor: AppColors.darkTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: NotificationsAppBar(
            unreadCount: state.unreadCount,
            onBack: () => Navigator.pop(context),
          ),
          body: Builder(
            builder: (context) {
              if (state.isError && state.allNotifications.isEmpty) {
                return NotificationsErrorState(
                  message: state.errorMessage ?? '',
                  onRetry: () => cubit.retry(),
                );
              }

              if (state.isLoading && state.allNotifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkTeal,
                  ),
                );
              }

              if (state.isEmpty) {
                return const NotificationsEmptyState();
              }

              final todayItems = state.todayNotifications;
              final yesterdayItems = state.yesterdayNotifications;
              final olderItems = state.olderNotifications;

              return RefreshIndicator(
                color: AppColors.darkTeal,
                onRefresh: () async {
                  await cubit.retry();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    if (todayItems.isNotEmpty)
                      NotificationSection(
                        title: LocaleKeys.today.tr(),
                        notifications: todayItems,
                        onMarkAllAsRead: () {
                          cubit.markSectionAsRead(
                            todayItems.map((n) => n.id).toList(),
                          );
                        },
                        onNotificationTap: (notification) =>
                            _handleNotificationTap(context, notification),
                      ),
                    if (yesterdayItems.isNotEmpty)
                      NotificationSection(
                        title: LocaleKeys.yesterday.tr(),
                        notifications: yesterdayItems,
                        onMarkAllAsRead: () {
                          cubit.markSectionAsRead(
                            yesterdayItems.map((n) => n.id).toList(),
                          );
                        },
                        onNotificationTap: (notification) =>
                            _handleNotificationTap(context, notification),
                      ),
                    if (olderItems.isNotEmpty)
                      NotificationSection(
                        title: LocaleKeys.older.tr(),
                        notifications: olderItems,
                        onMarkAllAsRead: () {
                          cubit.markSectionAsRead(
                            olderItems.map((n) => n.id).toList(),
                          );
                        },
                        onNotificationTap: (notification) =>
                            _handleNotificationTap(context, notification),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
