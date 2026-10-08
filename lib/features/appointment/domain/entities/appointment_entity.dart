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
  ];
}
