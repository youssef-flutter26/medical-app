abstract class FavoriteRepository {
  Stream<Set<String>> getFavoriteDoctorIdsStream(String userId);
  Stream<Set<String>> getFavoriteMedicalCenterIdsStream(String userId);
  Future<Set<String>> getInitialFavoriteDoctorIds(String userId);
  Future<Set<String>> getInitialFavoriteMedicalCenterIds(String userId);
  Future<void> addDoctorFavorite(String userId, String doctorId);
  Future<void> removeDoctorFavorite(String userId, String doctorId);
  Future<void> addMedicalCenterFavorite(String userId, String centerId);
  Future<void> removeMedicalCenterFavorite(String userId, String centerId);
}
