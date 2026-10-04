import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/data/models/medical_center_model.dart';
import 'package:medical_app/features/location/data/models/medical_place_model.dart';
import 'package:medical_app/features/location/domain/entities/medical_place.dart';

import '../../../home/data/models/doctor_model.dart';
import 'location_remote_data_source.dart';

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  LocationRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<MedicalPlaceModel>> getMedicalPlaces() async {
    final results = await Future.wait([
      _firestore.collection('doctors').get(),
      _firestore.collection('medical_centers').get(),
    ]);

    final doctorsSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;

    final centersSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;

    final places = <MedicalPlaceModel>[];

    for (final doc in doctorsSnapshot.docs) {
      final doctor = DoctorModel.fromFirestore(doc.data(), doc.id);

      if (doctor.latitude == null || doctor.longitude == null) {
        continue;
      }

      places.add(
        MedicalPlaceModel(
          id: 'doctor_${doctor.id ?? doc.id}',
          name: doctor.name,
          address: doctor.address,
          latitude: doctor.latitude!,
          longitude: doctor.longitude!,
          rating: doctor.rating,
          reviewsCount: doctor.reviewsCount,

          // Will be calculated by
          // LocationRepositoryImpl.
          distance: 0.0,

          type: MedicalPlaceType.doctor,
          imageUrl: doctor.imagePath,
          specialty: doctor.specialty,
        ),
      );
    }

    for (final doc in centersSnapshot.docs) {
      final center = MedicalCenterModel.fromFirestore(doc.data(), doc.id);

      if (center.latitude == null || center.longitude == null) {
        continue;
      }

      final normalizedType = center.type.trim().toLowerCase();

      final MedicalPlaceType type;

      if (normalizedType.contains('clinic')) {
        type = MedicalPlaceType.clinic;
      } else {
        type = MedicalPlaceType.hospital;
      }

      places.add(
        MedicalPlaceModel(
          id: 'center_${center.id ?? doc.id}',
          name: center.name,
          address: center.address,
          latitude: center.latitude!,
          longitude: center.longitude!,
          rating: center.rating,
          reviewsCount: center.reviewsCount,

          // Will be calculated by
          // LocationRepositoryImpl.
          distance: 0.0,

          type: type,
          imageUrl: center.imagePath,
        ),
      );
    }

    return places;
  }
}
