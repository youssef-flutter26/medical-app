import 'package:medical_app/core/error/result.dart';
import '../repositories/appointment_repository.dart';

class CancelAppointment {
  const CancelAppointment(this._repository);

  final AppointmentRepository _repository;

  Future<Result<void>> call(String appointmentId) {
    return _repository.cancelAppointment(appointmentId);
  }
}
