import 'package:medical_app/core/error/app_exception.dart';
import 'package:medical_app/core/error/result.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._remoteDataSource);

  final AppointmentRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Set<String>>> getBookedSlots({
    required String doctorId,
    required String dateKey,
  }) async {
    try {
      final result = await _remoteDataSource.getBookedSlots(
        doctorId: doctorId,
        dateKey: dateKey,
      );

      return SuccessAPI(result);
    } on AppException catch (e) {
      return ErrorAPI(_AppointmentFailure(e.message));
    } catch (e) {
      return ErrorAPI(
        _AppointmentFailure('Failed to load booked appointments: $e'),
      );
    }
  }

  @override
  Future<Result<void>> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String dateKey,
    required String time,
    required DateTime dateTime,
    String? doctorSpecialty,
    String? doctorAddress,
    String? doctorImagePath,
  }) async {
    try {
      await _remoteDataSource.bookAppointment(
        doctorId: doctorId,
        doctorName: doctorName,
        patientId: patientId,
        dateKey: dateKey,
        time: time,
        dateTime: dateTime,
        doctorSpecialty: doctorSpecialty,
        doctorAddress: doctorAddress,
        doctorImagePath: doctorImagePath,
      );

      return const SuccessAPI(null);
    } on AppException catch (e) {
      return ErrorAPI(_AppointmentFailure(e.message));
    } catch (e) {
      return ErrorAPI(_AppointmentFailure(e.toString()));
    }
  }
}

class _AppointmentFailure extends Failure {
  _AppointmentFailure(super.message);
}
