import 'package:cloud_firestore/cloud_firestore.dart';

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

      transaction.set(appointmentReference, {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': patientId,
        'dateKey': dateKey,
        'time': time,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
