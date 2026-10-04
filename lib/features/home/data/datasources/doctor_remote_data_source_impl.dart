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
  Future<void> updateDoctor(DoctorModel doctor) async {
    final docId = doctor.id;
    if (docId == null || docId.isEmpty) {
      throw ArgumentError('Doctor id is required for update');
    }
    try {
      final data = doctor.toFirestore();
      debugPrint('Firestore updating doctor $docId with: $data');
      await firestore.collection('doctors').doc(docId).update(data);
      debugPrint('Firestore successfully updated doctor $docId');
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore updateDoctor FirebaseException: [${e.code}] ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Firestore updateDoctor error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<DoctorModel>> getDoctorsStream() {
    return firestore.collection('doctors').snapshots().map(
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
        list.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        return list;
      },
    );
  }

  @override
  Stream<List<DoctorModel>> getDoctorsByCategoryStream(String categoryId) {
    return firestore
        .collection('doctors')
        .snapshots()
        .map(
      (snapshot) {
        debugPrint(
          'DoctorRemoteDataSource: received ${snapshot.docs.length} docs for category $categoryId',
        );
        final list = <DoctorModel>[];
        final target = categoryId.trim().toLowerCase();
        for (final doc in snapshot.docs) {
          try {
            final model = DoctorModel.fromFirestore(doc.data(), doc.id);
            final docCat = model.categoryName.trim().toLowerCase();
            final docSpec = model.specialty.trim().toLowerCase();
            final docCatId = model.categoryId.trim();

            final matches = target.isEmpty ||
                target == 'all doctors' ||
                (docCatId.isNotEmpty &&
                    (docCatId == categoryId.trim() ||
                        docCatId.toLowerCase() == target)) ||
                docCat == target ||
                docSpec == target ||
                (target.length >= 3 &&
                    (docCat.contains(target) ||
                        target.contains(docCat) ||
                        docSpec.contains(target) ||
                        target.contains(docSpec)));
            if (matches) {
              list.add(model);
            }
          } catch (e, stack) {
            debugPrint('Error parsing doctor doc ${doc.id}: $e\n$stack');
          }
        }
        list.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        return list;
      },
    );
  }
}
