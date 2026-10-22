import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveUser(UserModel user) async {
    final data = user.toFirestore();
    if (user.photoUrl == null || user.photoUrl!.trim().isEmpty) {
      data['photoUrl'] = FieldValue.delete();
    }
    await firestore
        .collection('users')
        .doc(user.id)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> deleteUserPhoto(String uid) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'photoUrl': FieldValue.delete(),
      });
    } catch (_) {
      await firestore.collection('users').doc(uid).set({
        'photoUrl': FieldValue.delete(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return UserModel.fromFirestore(snapshot.data()!);
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }

          return UserModel.fromFirestore(snapshot.data()!);
        })
        .handleError((_) => null);
  }
}
