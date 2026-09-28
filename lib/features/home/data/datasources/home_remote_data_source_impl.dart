import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/data/models/banner_model.dart';
import 'home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSourceImpl([FirebaseFirestore? firestore])
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<BannerModel>> getBannersStream() {
    return firestore.collection('banners').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  @override
  Future<void> addBanner(BannerModel banner) async {
    await firestore.collection('banners').add(banner.toFirestore());
  }
}
