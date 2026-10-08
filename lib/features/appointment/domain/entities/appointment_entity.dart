import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  const AppointmentEntity({
    this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.dateKey,
    required this.time,
    required this.dateTime,
    required this.status,
    this.createdAt,
    this.doctorSpecialty,
    this.doctorAddress,
    this.doctorImagePath,
  });

  final String? id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String dateKey;
  final String time;
  final DateTime dateTime;
  final String status;
  final DateTime? createdAt;
  final String? doctorSpecialty;
  final String? doctorAddress;
  final String? doctorImagePath;

  AppointmentEntity copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? patientId,
    String? dateKey,
    String? time,
    DateTime? dateTime,
    String? status,
    DateTime? createdAt,
    String? doctorSpecialty,
    String? doctorAddress,
    String? doctorImagePath,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      patientId: patientId ?? this.patientId,
      dateKey: dateKey ?? this.dateKey,
      time: time ?? this.time,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorAddress: doctorAddress ?? this.doctorAddress,
      doctorImagePath: doctorImagePath ?? this.doctorImagePath,
    );
  }

  @override
  List<Object?> get props => [
    id,
    doctorId,
    doctorName,
    patientId,
    dateKey,
    time,
    dateTime,
    status,
    createdAt,
    doctorSpecialty,
    doctorAddress,
    doctorImagePath,
  ];
}
