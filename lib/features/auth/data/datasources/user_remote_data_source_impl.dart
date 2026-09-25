import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveUser(UserModel user) async {
    await firestore
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return UserModel.fromFirestore(snapshot.data()!);
  }
}
