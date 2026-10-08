import 'package:medical_app/core/error/result.dart';

import '../repositories/appointment_repository.dart';

class BookAppointment {
  const BookAppointment(this._repository);

  final AppointmentRepository _repository;

  Future<Result<void>> call({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
  }) {
    return _repository.bookAppointment(
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      dateKey: dateKey,
      time: time,
      dateTime: dateTime,
    );
  }
}
