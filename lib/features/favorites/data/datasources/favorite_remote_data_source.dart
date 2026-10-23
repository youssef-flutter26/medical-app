import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FavoriteRemoteDataSource {
  Stream<Set<String>> getFavoriteDoctorIdsStream(String userId);
  Stream<Set<String>> getFavoriteMedicalCenterIdsStream(String userId);
  Future<Set<String>> getFavoriteDoctorIds(String userId);
  Future<Set<String>> getFavoriteMedicalCenterIds(String userId);
  Future<void> addFavoriteDoctor(String userId, String doctorId);
  Future<void> removeFavoriteDoctor(String userId, String doctorId);
  Future<void> addFavoriteMedicalCenter(String userId, String centerId);
  Future<void> removeFavoriteMedicalCenter(String userId, String centerId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoriteRemoteDataSourceImpl(this.firestore);

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      firestore.collection('users').doc(userId);

  @override
  Stream<Set<String>> getFavoriteDoctorIdsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<String>{});
    }

    return _userDoc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return <String>{};
      }
      final data = snapshot.data()!;
      final list = data['favoriteDoctorIds'];
      if (list is List) {
        return list.map((e) => e.toString()).toSet();
      }
      return <String>{};
    }).handleError((_) => <String>{});
  }

  @override
  Stream<Set<String>> getFavoriteMedicalCenterIdsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<String>{});
    }

    return _userDoc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return <String>{};
      }
      final data = snapshot.data()!;
      final list = data['favoriteMedicalCenterIds'];
      if (list is List) {
        return list.map((e) => e.toString()).toSet();
      }
      return <String>{};
    }).handleError((_) => <String>{});
  }

  @override
  Future<Set<String>> getFavoriteDoctorIds(String userId) async {
    if (userId.isEmpty) return <String>{};
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists || doc.data() == null) return <String>{};
      final list = doc.data()!['favoriteDoctorIds'];
      if (list is List) {
        return list.map((e) => e.toString()).toSet();
      }
      return <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  @override
  Future<Set<String>> getFavoriteMedicalCenterIds(String userId) async {
    if (userId.isEmpty) return <String>{};
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists || doc.data() == null) return <String>{};
      final list = doc.data()!['favoriteMedicalCenterIds'];
      if (list is List) {
        return list.map((e) => e.toString()).toSet();
      }
      return <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  @override
  Future<void> addFavoriteDoctor(String userId, String doctorId) async {
    if (userId.isEmpty || doctorId.isEmpty) return;
    await _userDoc(userId).set({
      'favoriteDoctorIds': FieldValue.arrayUnion([doctorId]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeFavoriteDoctor(String userId, String doctorId) async {
    if (userId.isEmpty || doctorId.isEmpty) return;
    await _userDoc(userId).set({
      'favoriteDoctorIds': FieldValue.arrayRemove([doctorId]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> addFavoriteMedicalCenter(String userId, String centerId) async {
    if (userId.isEmpty || centerId.isEmpty) return;
    await _userDoc(userId).set({
      'favoriteMedicalCenterIds': FieldValue.arrayUnion([centerId]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeFavoriteMedicalCenter(
    String userId,
    String centerId,
  ) async {
    if (userId.isEmpty || centerId.isEmpty) return;
    await _userDoc(userId).set({
      'favoriteMedicalCenterIds': FieldValue.arrayRemove([centerId]),
    }, SetOptions(merge: true));
  }
}
