import 'package:medical_app/core/error/result.dart';
import '../repositories/appointment_repository.dart';

class RescheduleAppointment {
  final AppointmentRepository _repository;

  const RescheduleAppointment(this._repository);

  Future<Result<void>> call({
    required String appointmentId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
  }) {
    return _repository.rescheduleAppointment(
      appointmentId: appointmentId,
      dateKey: dateKey,
      time: time,
      dateTime: dateTime,
    );
  }
}
