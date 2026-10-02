import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_app/features/doctor/data/models/doctor_model.dart';
import 'doctor_remote_data_source.dart';

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final FirebaseFirestore firestore;

  DoctorRemoteDataSourceImpl([FirebaseFirestore? firestore])
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addDoctor(DoctorModel doctor) async {
    try {
      final data = doctor.toFirestore();
      debugPrint('Firestore adding to doctors: $data');
      await firestore.collection('doctors').add(data);
      debugPrint('Firestore successfully added document to doctors');
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore addDoctor FirebaseException: [${e.code}] ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Firestore addDoctor error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<DoctorModel>> getDoctorsStream() {
    return firestore
        .collection('doctors')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        debugPrint(
          'DoctorRemoteDataSource: received ${snapshot.docs.length} docs from doctors',
        );
        final list = <DoctorModel>[];
        for (final doc in snapshot.docs) {
          try {
            final model = DoctorModel.fromFirestore(doc.data(), doc.id);
            list.add(model);
          } catch (e, stack) {
            debugPrint('Error parsing doctor doc ${doc.id}: $e\n$stack');
          }
        }
        return list;
      },
    );
  }

  @override
  Stream<List<DoctorModel>> getDoctorsByCategoryStream(String categoryId) {
    return firestore
        .collection('doctors')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map(
      (snapshot) {
        debugPrint(
          'DoctorRemoteDataSource: received ${snapshot.docs.length} docs for category $categoryId',
        );
        final list = <DoctorModel>[];
        for (final doc in snapshot.docs) {
          try {
            final model = DoctorModel.fromFirestore(doc.data(), doc.id);
            list.add(model);
          } catch (e, stack) {
            debugPrint('Error parsing doctor doc ${doc.id}: $e\n$stack');
          }
        }
        return list;
      },
    );
  }
}
