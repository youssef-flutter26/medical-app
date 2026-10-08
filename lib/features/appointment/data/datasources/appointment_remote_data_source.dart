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
}
