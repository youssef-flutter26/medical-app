import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoriteLocalDataSource {
  Future<Set<String>> getFavoriteDoctorIds(String userId);
  Future<Set<String>> getFavoriteMedicalCenterIds(String userId);
  Future<void> saveFavoriteDoctorIds(String userId, Set<String> ids);
  Future<void> saveFavoriteMedicalCenterIds(String userId, Set<String> ids);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  final SharedPreferences? _prefs;

  FavoriteLocalDataSourceImpl([this._prefs]);

  Future<SharedPreferences> get _instance async =>
      _prefs ?? await SharedPreferences.getInstance();

  String _doctorKey(String userId) => 'favorite_doctors_$userId';
  String _medicalCenterKey(String userId) => 'favorite_medical_centers_$userId';

  @override
  Future<Set<String>> getFavoriteDoctorIds(String userId) async {
    final prefs = await _instance;
    final list = prefs.getStringList(_doctorKey(userId)) ?? [];
    return list.toSet();
  }

  @override
  Future<Set<String>> getFavoriteMedicalCenterIds(String userId) async {
    final prefs = await _instance;
    final list =
        prefs.getStringList(_medicalCenterKey(userId)) ?? [];
    return list.toSet();
  }

  @override
  Future<void> saveFavoriteDoctorIds(String userId, Set<String> ids) async {
    final prefs = await _instance;
    await prefs.setStringList(_doctorKey(userId), ids.toList());
  }

  @override
  Future<void> saveFavoriteMedicalCenterIds(
    String userId,
    Set<String> ids,
  ) async {
    final prefs = await _instance;
    await prefs.setStringList(
      _medicalCenterKey(userId),
      ids.toList(),
    );
  }
}
