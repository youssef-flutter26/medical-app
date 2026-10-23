import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _notificationRepository;
  final FirebaseAuth? _firebaseAuth;

  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _authSubscription;
  Timer? _timeoutTimer;
  String _currentUserId = '';

  NotificationsCubit({
    required NotificationRepository notificationRepository,
    FirebaseAuth? firebaseAuth,
  })  : _notificationRepository = notificationRepository,
        _firebaseAuth = firebaseAuth,
        super(const NotificationsState());

  void init() {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final auth = _firebaseAuth;
    if (auth != null) {
      _currentUserId = auth.currentUser?.uid ?? '';
      _subscribeToNotifications(_currentUserId);

      _authSubscription?.cancel();
      _authSubscription = auth.authStateChanges().listen((user) {
        final newUid = user?.uid ?? '';
        if (newUid != _currentUserId) {
          _currentUserId = newUid;
          _subscribeToNotifications(_currentUserId);
        }
      });
    } else {
      try {
        final fbAuth = FirebaseAuth.instance;
        _currentUserId = fbAuth.currentUser?.uid ?? '';
        _subscribeToNotifications(_currentUserId);

        _authSubscription?.cancel();
        _authSubscription = fbAuth.authStateChanges().listen((user) {
          final newUid = user?.uid ?? '';
          if (newUid != _currentUserId) {
            _currentUserId = newUid;
            _subscribeToNotifications(_currentUserId);
          }
        });
      } catch (_) {
        _subscribeToNotifications('');
      }
    }
  }

  void _subscribeToNotifications(String userId) {
    _notificationsSubscription?.cancel();
    _timeoutTimer?.cancel();

    // Timeout safety net to prevent any indefinite loading
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (state.isLoading) {
        emit(state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: 'Unable to load notifications. Please check your connection and try again.',
        ));
      }
    });

    _notificationsSubscription = _notificationRepository
        .getNotificationsStream(userId)
        .listen(
      (notifications) {
        _timeoutTimer?.cancel();
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          allNotifications: notifications,
        ));
      },
      onError: (error) {
        _timeoutTimer?.cancel();
        emit(state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<void> retry() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      await _notificationRepository.refresh(_currentUserId);
    } catch (_) {}
    _subscribeToNotifications(_currentUserId);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(_currentUserId, notificationId);
    } catch (_) {}
  }

  Future<void> markSectionAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    try {
      await _notificationRepository.markSectionAsRead(
        _currentUserId,
        notificationIds,
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead(_currentUserId);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    _notificationsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
