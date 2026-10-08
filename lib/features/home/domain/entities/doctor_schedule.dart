import 'package:equatable/equatable.dart';

class DoctorDaySchedule extends Equatable {
  const DoctorDaySchedule({
    required this.dayOfWeek,
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  final int dayOfWeek;

  final bool enabled;

  final String startTime;

  final String endTime;

  DoctorDaySchedule copyWith({
    int? dayOfWeek,
    bool? enabled,
    String? startTime,
    String? endTime,
  }) {
    return DoctorDaySchedule(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {'enabled': enabled, 'startTime': startTime, 'endTime': endTime};
  }

  factory DoctorDaySchedule.fromMap(int dayOfWeek, Map<String, dynamic> map) {
    return DoctorDaySchedule(
      dayOfWeek: dayOfWeek,
      enabled: map['enabled'] == true,
      startTime: map['startTime']?.toString() ?? '09:00',
      endTime: map['endTime']?.toString() ?? '17:00',
    );
  }

  @override
  List<Object?> get props => [dayOfWeek, enabled, startTime, endTime];
}
