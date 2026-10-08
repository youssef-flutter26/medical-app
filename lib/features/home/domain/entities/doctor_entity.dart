import 'package:equatable/equatable.dart';

class DoctorSchedule extends Equatable {
  const DoctorSchedule({
    required this.day,
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  final String day;
  final bool enabled;
  final String startTime;
  final String endTime;

  DoctorSchedule copyWith({
    String? day,
    bool? enabled,
    String? startTime,
    String? endTime,
  }) {
    return DoctorSchedule(
      day: day ?? this.day,
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  static List<DoctorSchedule> defaultWeek() {
    return const [
      DoctorSchedule(
        day: 'sunday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'monday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'tuesday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'wednesday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'thursday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'friday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
      DoctorSchedule(
        day: 'saturday',
        enabled: false,
        startTime: '09:00',
        endTime: '17:00',
      ),
    ];
  }

  @override
  List<Object?> get props =>
      [
        day,
        enabled,
        startTime,
        endTime,
      ];
}

class DoctorEntity extends Equatable {
  const DoctorEntity({
    this.id,
    required this.name,
    required this.specialty,
    required this.categoryId,
    required this.categoryName,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.availableTime,
    required this.imagePath,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.schedule = const [],
  });

  final String? id;
  final String name;
  final String specialty;
  final String categoryId;
  final String categoryName;
  final String address;
  final double rating;
  final int reviewsCount;
  final String availableTime;
  final String imagePath;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;
  final List<DoctorSchedule> schedule;

  @override
  List<Object?> get props => [
    id,
    name,
    specialty,
    categoryId,
    categoryName,
    address,
    rating,
    reviewsCount,
    availableTime,
    imagePath,
    createdAt,
    latitude,
    longitude,
    schedule,
  ];
}