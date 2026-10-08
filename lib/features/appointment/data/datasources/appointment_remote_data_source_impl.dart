import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/appointment_model.dart';
import 'appointment_remote_data_source.dart';

class AppointmentAlreadyBookedException implements Exception {
  const AppointmentAlreadyBookedException();

  @override
  String toString() => 'AppointmentAlreadyBookedException';
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  AppointmentRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Set<String>> getBookedSlots({
    required String doctorId,
    required String dateKey,
  }) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateKey', isEqualTo: dateKey)
        .where('status', isEqualTo: 'booked')
        .get();

    final result = <String>{};

    for (final document in snapshot.docs) {
      final data = document.data();

      final time = data['time']?.toString();

      if (time != null && time.isNotEmpty) {
        result.add(time);
      }
    }

    return result;
  }

  @override
  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
    String? doctorSpecialty,
    String? doctorAddress,
    String? doctorImagePath,
  }) async {
    final documentId = '${doctorId}_${dateKey}_$time';

    final appointmentReference = _firestore
        .collection('appointments')
        .doc(documentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(appointmentReference);

      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null && data['status'] == 'booked') {
          throw const AppointmentAlreadyBookedException();
        }
      }

      final appointmentData = <String, dynamic>{
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': patientId,
        'dateKey': dateKey,
        'time': time,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (doctorSpecialty != null && doctorSpecialty.isNotEmpty) {
        appointmentData['doctorSpecialty'] = doctorSpecialty;
      }
      if (doctorAddress != null && doctorAddress.isNotEmpty) {
        appointmentData['doctorAddress'] = doctorAddress;
      }
      if (doctorImagePath != null && doctorImagePath.isNotEmpty) {
        appointmentData['doctorImagePath'] = doctorImagePath;
      }

      transaction.set(appointmentReference, appointmentData);
    });
  }

  @override
  Stream<List<AppointmentModel>> streamUserAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    });
  }

  @override
  Future<List<AppointmentModel>> getUserAppointments(String patientId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();

    final list = snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'canceled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
  }) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'dateKey': dateKey,
      'time': time,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': 'upcoming',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
