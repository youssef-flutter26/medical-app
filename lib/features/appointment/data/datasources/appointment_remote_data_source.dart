import '../model/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<Set<String>> getBookedSlots({
    required String doctorId,
    required String dateKey,
  });

  Future<void> bookAppointment({
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

  Stream<List<AppointmentModel>> streamUserAppointments(String patientId);

  Future<List<AppointmentModel>> getUserAppointments(String patientId);

  Future<void> cancelAppointment(String appointmentId);
}
