import '../entities/assistant_doctor.dart';

abstract class AssistantRepository {
  Future<List<AssistantDoctor>> searchNearbyDoctors({
    required double latitude,
    required double longitude,
    required String query,
    double radiusInKm = 10,
  });

  Future<String> sendMessage({
    required String message,
    required double latitude,
    required double longitude,
    required List<AssistantDoctor> nearbyDoctors,
  });
}
