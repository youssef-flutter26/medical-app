import 'package:medical_app/features/home/data/models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<void> addDoctor(DoctorModel doctor);
  Future<void> updateDoctor(DoctorModel doctor);
  Stream<List<DoctorModel>> getDoctorsStream();
  Stream<List<DoctorModel>> getDoctorsByCategoryStream(String categoryId);
  Future<DoctorModel?> getDoctorById(String doctorId);
}
