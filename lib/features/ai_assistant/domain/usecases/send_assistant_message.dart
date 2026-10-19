import '../entities/assistant_doctor.dart';
import '../repositories/assistant_repository.dart';

class SendAssistantMessage {
  const SendAssistantMessage(this._repository);

  final AssistantRepository _repository;

  Future<List<AssistantDoctor>> searchNearbyDoctors({
    required double latitude,
    required double longitude,
    required String query,
    double radiusInKm = 15,
  }) {
    return _repository.searchNearbyDoctors(
      latitude: latitude,
      longitude: longitude,
      query: query,
      radiusInKm: radiusInKm,
    );
  }

  /// إرسال رسالة المساعد مع الدكاترة اللي تم العثور عليهم.
  Future<String> call({
    required String message,
    required double latitude,
    required double longitude,
    required List<AssistantDoctor> nearbyDoctors,
  }) {
    return _repository.sendMessage(
      message: message,
      latitude: latitude,
      longitude: longitude,
      nearbyDoctors: nearbyDoctors,
    );
  }
}
