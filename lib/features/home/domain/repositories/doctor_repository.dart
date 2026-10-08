import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<Result<void>> addDoctor(DoctorEntity doctor);
  Future<Result<void>> updateDoctor(DoctorEntity doctor);
  Stream<List<DoctorEntity>> getDoctorsStream();
  Stream<List<DoctorEntity>> getDoctorsByCategoryStream(String categoryId);
  Future<Result<DoctorEntity?>> getDoctorById(String doctorId);
}
