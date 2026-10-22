import 'dart:async';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;

  final StreamController<List<NotificationEntity>> _notificationsController =
      StreamController<List<NotificationEntity>>.broadcast();

  List<NotificationEntity> _latestNotifications = [];
  Set<String> _readIds = {};
  StreamSubscription? _remoteSubscription;
  String? _currentUserId;
  bool _hasInitialData = false;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required NotificationLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Stream<List<NotificationEntity>> getNotificationsStream(String userId) async* {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _hasInitialData = false;
      _latestNotifications = [];
      _readIds = await _localDataSource.getReadNotificationIds(userId);
      _remoteSubscription?.cancel();
      _startRemoteSubscription(userId);
    } else {
      _readIds = await _localDataSource.getReadNotificationIds(userId);
      if (_remoteSubscription == null) {
        _startRemoteSubscription(userId);
      }
    }

    if (_hasInitialData) {
      yield _getUpdatedList();
    }

    yield* _notificationsController.stream;
  }

  void _startRemoteSubscription(String userId) {
    _remoteSubscription?.cancel();
    _remoteSubscription = _remoteDataSource.streamNotifications(userId).listen(
      (rawList) {
        _latestNotifications = rawList;
        _hasInitialData = true;
        _emitUpdated();
      },
      onError: (error) {
        if (!_notificationsController.isClosed) {
          _notificationsController.addError(error);
        }
      },
    );
  }

  @override
  Future<void> refresh(String userId) async {
    _currentUserId = userId;
    _readIds = await _localDataSource.getReadNotificationIds(userId);
    _startRemoteSubscription(userId);
  }

  List<NotificationEntity> _getUpdatedList() {
    return _latestNotifications.map((notif) {
      final isLocallyRead = _readIds.contains(notif.id);
      return notif.copyWith(isRead: notif.isRead || isLocallyRead);
    }).toList();
  }

  void _emitUpdated() {
    if (!_notificationsController.isClosed) {
      _notificationsController.add(_getUpdatedList());
    }
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    _readIds.add(notificationId);
    await _localDataSource.markAsRead(userId, notificationId);
    await _remoteDataSource.markAsReadInRemote(userId, notificationId);
    _emitUpdated();
  }

  @override
  Future<void> markSectionAsRead(
    String userId,
    List<String> notificationIds,
  ) async {
    _readIds.addAll(notificationIds);
    await _localDataSource.markMultipleAsRead(userId, notificationIds);
    for (final id in notificationIds) {
      await _remoteDataSource.markAsReadInRemote(userId, id);
    }
    _emitUpdated();
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final allIds = _latestNotifications.map((e) => e.id).toList();
    _readIds.addAll(allIds);
    await _localDataSource.markMultipleAsRead(userId, allIds);
    for (final id in allIds) {
      await _remoteDataSource.markAsReadInRemote(userId, id);
    }
    _emitUpdated();
  }
}
