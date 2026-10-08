import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/data/datasources/doctor_remote_data_source.dart';
import 'package:medical_app/features/home/data/models/doctor_model.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<void>> addDoctor(DoctorEntity doctor) async {
    try {
      await remoteDataSource.addDoctor(DoctorModel.fromEntity(doctor));
      return const SuccessAPI(null);
    } catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }

  @override
  Future<Result<void>> updateDoctor(DoctorEntity doctor) async {
    try {
      await remoteDataSource.updateDoctor(DoctorModel.fromEntity(doctor));
      return const SuccessAPI(null);
    } catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }

  @override
  Stream<List<DoctorEntity>> getDoctorsStream() {
    return remoteDataSource.getDoctorsStream();
  }

  @override
  Stream<List<DoctorEntity>> getDoctorsByCategoryStream(String categoryId) {
    return remoteDataSource.getDoctorsByCategoryStream(categoryId);
  }

  @override
  Future<Result<DoctorEntity?>> getDoctorById(String doctorId) async {
    try {
      final doctor = await remoteDataSource.getDoctorById(doctorId);
      return SuccessAPI(doctor);
    } catch (e) {
      return ErrorAPI(FirebaseFailure.fromException(e));
    }
  }
}
