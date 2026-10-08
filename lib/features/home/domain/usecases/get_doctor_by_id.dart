import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/repositories/doctor_repository.dart';

class GetDoctorById {
  final DoctorRepository repository;

  GetDoctorById(this.repository);

  Future<Result<DoctorEntity?>> call(String doctorId) {
    return repository.getDoctorById(doctorId);
  }
}
