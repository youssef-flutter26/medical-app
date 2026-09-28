import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:medical_app/features/admin/data/models/banner_model.dart';

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> addBanner(BannerModel banner) async {
    await firestore.collection('banners').add(banner.toFirestore());
  }
}
