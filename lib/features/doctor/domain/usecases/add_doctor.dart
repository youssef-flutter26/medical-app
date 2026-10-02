import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/domain/repositories/doctor_repository.dart';

class AddDoctor {
  final DoctorRepository repository;

  AddDoctor(this.repository);

  Future<Result<void>> call(DoctorEntity doctor) {
    return repository.addDoctor(doctor);
  }
}
