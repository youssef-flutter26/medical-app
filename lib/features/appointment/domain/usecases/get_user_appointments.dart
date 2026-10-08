import 'package:medical_app/core/error/result.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetUserAppointments {
  const GetUserAppointments(this._repository);

  final AppointmentRepository _repository;

  Future<Result<List<AppointmentEntity>>> call(String patientId) {
    return _repository.getUserAppointments(patientId);
  }
}
