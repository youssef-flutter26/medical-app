import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/repositories/doctor_repository.dart';

class GetDoctorsStream {
  final DoctorRepository repository;

  GetDoctorsStream(this.repository);

  Stream<List<DoctorEntity>> call() {
    return repository.getDoctorsStream();
  }
}
