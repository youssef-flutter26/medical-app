import 'package:equatable/equatable.dart';

import '../../domain/entities/assistant_doctor.dart';
import '../../domain/entities/assistant_message.dart';

enum AssistantStatus { initial, gettingLocation, loading, success, failure }

class AssistantState extends Equatable {
  const AssistantState({
    this.status = AssistantStatus.initial,
    this.messages = const [],
    this.nearbyDoctors = const [],
    this.latitude,
    this.longitude,
    this.errorMessage,
  });

  final AssistantStatus status;
  final List<AssistantMessage> messages;
  final List<AssistantDoctor> nearbyDoctors;

  final double? latitude;
  final double? longitude;

  final String? errorMessage;

  bool get hasLocation => latitude != null && longitude != null;

  AssistantState copyWith({
    AssistantStatus? status,
    List<AssistantMessage>? messages,
    List<AssistantDoctor>? nearbyDoctors,
    double? latitude,
    double? longitude,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      nearbyDoctors: nearbyDoctors ?? this.nearbyDoctors,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    nearbyDoctors,
    latitude,
    longitude,
    errorMessage,
  ];
}
