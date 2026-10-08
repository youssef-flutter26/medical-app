import 'package:medical_app/core/error/result.dart';

import '../repositories/appointment_repository.dart';

class GetBookedSlots {
  const GetBookedSlots(this._repository);

  final AppointmentRepository _repository;

  Future<Result<Set<String>>> call({
    required String doctorId,
    required String dateKey,
  }) {
    return _repository.getBookedSlots(doctorId: doctorId, dateKey: dateKey);
  }
}
