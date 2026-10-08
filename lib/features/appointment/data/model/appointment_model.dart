import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    super.id,
    required super.doctorId,
    required super.doctorName,
    required super.patientId,
    required super.dateKey,
    required super.time,
    required super.dateTime,
    required super.status,
    super.createdAt,
    super.doctorSpecialty,
    super.doctorAddress,
    super.doctorImagePath,
  });

  factory AppointmentModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    DateTime dateTime;

    final rawDateTime = json['dateTime'];

    if (rawDateTime is Timestamp) {
      dateTime = rawDateTime.toDate();
    } else if (rawDateTime is String) {
      dateTime = DateTime.tryParse(rawDateTime) ?? DateTime.now();
    } else {
      dateTime = DateTime.now();
    }

    DateTime? createdAt;

    final rawCreatedAt = json['createdAt'];

    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    return AppointmentModel(
      id: docId,
      doctorId: json['doctorId']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      dateKey: json['dateKey']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      dateTime: dateTime,
      status: json['status']?.toString() ?? 'booked',
      createdAt: createdAt,
      doctorSpecialty: json['doctorSpecialty']?.toString(),
      doctorAddress: json['doctorAddress']?.toString(),
      doctorImagePath: json['doctorImagePath']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'dateKey': dateKey,
      'time': time,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (doctorSpecialty != null) map['doctorSpecialty'] = doctorSpecialty;
    if (doctorAddress != null) map['doctorAddress'] = doctorAddress;
    if (doctorImagePath != null) map['doctorImagePath'] = doctorImagePath;
    return map;
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      patientId: entity.patientId,
      dateKey: entity.dateKey,
      time: entity.time,
      dateTime: entity.dateTime,
      status: entity.status,
      createdAt: entity.createdAt,
      doctorSpecialty: entity.doctorSpecialty,
      doctorAddress: entity.doctorAddress,
      doctorImagePath: entity.doctorImagePath,
    );
  }
}
