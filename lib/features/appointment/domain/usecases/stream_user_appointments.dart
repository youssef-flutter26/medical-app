import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class StreamUserAppointments {
  const StreamUserAppointments(this._repository);

  final AppointmentRepository _repository;

  Stream<List<AppointmentEntity>> call(String patientId) {
    return _repository.streamUserAppointments(patientId);
  }
}
