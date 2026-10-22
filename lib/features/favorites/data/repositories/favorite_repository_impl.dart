import 'package:flutter/foundation.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_data_source.dart';
import '../datasources/favorite_remote_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource localDataSource;
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Stream<Set<String>> getFavoriteDoctorIdsStream(String userId) {
    return remoteDataSource.getFavoriteDoctorIdsStream(userId).map((remoteIds) {
      localDataSource.saveFavoriteDoctorIds(userId, remoteIds);
      return remoteIds;
    });
  }

  @override
  Stream<Set<String>> getFavoriteMedicalCenterIdsStream(String userId) {
    return remoteDataSource
        .getFavoriteMedicalCenterIdsStream(userId)
        .map((remoteIds) {
      localDataSource.saveFavoriteMedicalCenterIds(userId, remoteIds);
      return remoteIds;
    });
  }

  @override
  Future<Set<String>> getInitialFavoriteDoctorIds(String userId) async {
    final localIds = await localDataSource.getFavoriteDoctorIds(userId);
    if (localIds.isNotEmpty) {
      // Refresh in background
      remoteDataSource.getFavoriteDoctorIds(userId).then((remoteIds) {
        if (remoteIds.isNotEmpty) {
          localDataSource.saveFavoriteDoctorIds(userId, remoteIds);
        }
      }).catchError((e) {
        debugPrint('Error syncing remote favorite doctors: $e');
      });
      return localIds;
    }
    final remoteIds = await remoteDataSource.getFavoriteDoctorIds(userId);
    if (remoteIds.isNotEmpty) {
      await localDataSource.saveFavoriteDoctorIds(userId, remoteIds);
    }
    return remoteIds;
  }

  @override
  Future<Set<String>> getInitialFavoriteMedicalCenterIds(String userId) async {
    final localIds = await localDataSource.getFavoriteMedicalCenterIds(userId);
    if (localIds.isNotEmpty) {
      // Refresh in background
      remoteDataSource.getFavoriteMedicalCenterIds(userId).then((remoteIds) {
        if (remoteIds.isNotEmpty) {
          localDataSource.saveFavoriteMedicalCenterIds(userId, remoteIds);
        }
      }).catchError((e) {
        debugPrint('Error syncing remote favorite medical centers: $e');
      });
      return localIds;
    }
    final remoteIds = await remoteDataSource.getFavoriteMedicalCenterIds(userId);
    if (remoteIds.isNotEmpty) {
      await localDataSource.saveFavoriteMedicalCenterIds(userId, remoteIds);
    }
    return remoteIds;
  }

  @override
  Future<void> addDoctorFavorite(String userId, String doctorId) async {
    final current = await localDataSource.getFavoriteDoctorIds(userId);
    current.add(doctorId);
    await localDataSource.saveFavoriteDoctorIds(userId, current);
    try {
      await remoteDataSource.addFavoriteDoctor(userId, doctorId);
    } catch (e) {
      debugPrint('Error adding remote doctor favorite: $e');
    }
  }

  @override
  Future<void> removeDoctorFavorite(String userId, String doctorId) async {
    final current = await localDataSource.getFavoriteDoctorIds(userId);
    current.remove(doctorId);
    await localDataSource.saveFavoriteDoctorIds(userId, current);
    try {
      await remoteDataSource.removeFavoriteDoctor(userId, doctorId);
    } catch (e) {
      debugPrint('Error removing remote doctor favorite: $e');
    }
  }

  @override
  Future<void> addMedicalCenterFavorite(String userId, String centerId) async {
    final current = await localDataSource.getFavoriteMedicalCenterIds(userId);
    current.add(centerId);
    await localDataSource.saveFavoriteMedicalCenterIds(userId, current);
    try {
      await remoteDataSource.addFavoriteMedicalCenter(userId, centerId);
    } catch (e) {
      debugPrint('Error adding remote medical center favorite: $e');
    }
  }

  @override
  Future<void> removeMedicalCenterFavorite(
    String userId,
    String centerId,
  ) async {
    final current = await localDataSource.getFavoriteMedicalCenterIds(userId);
    current.remove(centerId);
    await localDataSource.saveFavoriteMedicalCenterIds(userId, current);
    try {
      await remoteDataSource.removeFavoriteMedicalCenter(userId, centerId);
    } catch (e) {
      debugPrint('Error removing remote medical center favorite: $e');
    }
  }
}
