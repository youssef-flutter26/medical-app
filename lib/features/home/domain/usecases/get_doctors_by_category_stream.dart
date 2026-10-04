import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/repositories/doctor_repository.dart';

class GetDoctorsByCategoryStream {
  final DoctorRepository repository;

  GetDoctorsByCategoryStream(this.repository);

  Stream<List<DoctorEntity>> call(String categoryId) {
    return repository.getDoctorsByCategoryStream(categoryId);
  }
}
