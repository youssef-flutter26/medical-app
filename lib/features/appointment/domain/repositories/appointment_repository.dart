import 'package:medical_app/core/error/result.dart';

abstract class AppointmentRepository {
  Future<Result<Set<String>>> getBookedSlots({
    required String doctorId,
    required String dateKey,
  });

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
  });
}
