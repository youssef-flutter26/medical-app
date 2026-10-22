import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationLocalDataSource {
  Future<Set<String>> getReadNotificationIds(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> markMultipleAsRead(String userId, List<String> notificationIds);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _keyPrefix = 'read_notifications_';

  String _getKey(String userId) => '$_keyPrefix$userId';

  @override
  Future<Set<String>> getReadNotificationIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_getKey(userId)) ?? [];
    return list.toSet();
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userId);
    final set = (prefs.getStringList(key) ?? []).toSet();
    set.add(notificationId);
    await prefs.setStringList(key, set.toList());
  }

  @override
  Future<void> markMultipleAsRead(
    String userId,
    List<String> notificationIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userId);
    final set = (prefs.getStringList(key) ?? []).toSet();
    set.addAll(notificationIds);
    await prefs.setStringList(key, set.toList());
  }
}
