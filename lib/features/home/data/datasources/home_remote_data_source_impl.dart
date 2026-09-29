import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/data/models/banner_model.dart';
import 'package:medical_app/features/home/data/models/medical_center_model.dart';
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

  @override
  Future<void> updateBanner(BannerModel banner) async {
    if (banner.id == null || banner.id!.isEmpty) {
      throw ArgumentError('Banner ID cannot be null or empty when updating');
    }
    final data = <String, dynamic>{
      'title': banner.title,
      'description': banner.description,
      'imagePath': banner.imagePath,
    };
    if (banner.createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(banner.createdAt!);
    }
    await firestore.collection('banners').doc(banner.id).update(data);
  }

  @override
  Stream<List<MedicalCenterModel>> getMedicalCentersStream() {
    return firestore.collection('medical_centers').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => MedicalCenterModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  @override
  Future<void> addMedicalCenter(MedicalCenterModel center) async {
    await firestore.collection('medical_centers').add(center.toFirestore());
  }

  @override
  Future<void> updateMedicalCenter(MedicalCenterModel center) async {
    if (center.id == null || center.id!.isEmpty) {
      throw ArgumentError('Medical Center ID cannot be null or empty when updating');
    }
    await firestore
        .collection('medical_centers')
        .doc(center.id)
        .update(center.toFirestore());
  }
}
