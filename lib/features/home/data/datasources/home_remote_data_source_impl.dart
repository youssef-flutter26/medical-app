import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      (snapshot) {
        debugPrint(
          'HomeRemoteDataSource: received ${snapshot.docs.length} docs from medical_centers',
        );
        final list = <MedicalCenterModel>[];
        for (final doc in snapshot.docs) {
          try {
            final model = MedicalCenterModel.fromFirestore(doc.data(), doc.id);
            list.add(model);
          } catch (e, stack) {
            debugPrint('Error parsing medical_center doc ${doc.id}: $e\n$stack');
          }
        }
        return list;
      },
    );
  }

  @override
  Future<void> addMedicalCenter(MedicalCenterModel center) async {
    try {
      final data = center.toFirestore();
      debugPrint('Firestore adding to medical_centers: $data');
      await firestore.collection('medical_centers').add(data);
      debugPrint('Firestore successfully added document to medical_centers');
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore addMedicalCenter FirebaseException: [${e.code}] ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Firestore addMedicalCenter error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMedicalCenter(MedicalCenterModel center) async {
    if (center.id == null || center.id!.isEmpty) {
      throw ArgumentError(
        'Medical Center ID cannot be null or empty when updating',
      );
    }
    try {
      final data = center.toFirestore();
      debugPrint(
        'Firestore updating document ${center.id} in medical_centers: $data',
      );
      await firestore
          .collection('medical_centers')
          .doc(center.id)
          .update(data);
      debugPrint(
        'Firestore successfully updated document ${center.id} in medical_centers',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore updateMedicalCenter FirebaseException: [${e.code}] ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Firestore updateMedicalCenter error: $e');
      rethrow;
    }
  }
}
