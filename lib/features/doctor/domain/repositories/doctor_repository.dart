import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<Result<void>> addDoctor(DoctorEntity doctor);
  Stream<List<DoctorEntity>> getDoctorsStream();
  Stream<List<DoctorEntity>> getDoctorsByCategoryStream(String categoryId);
}
