class AssistantDoctor {
  const AssistantDoctor({
    required this.id,
    required this.name,
    this.specialty,
    this.address,
    this.rating,
    this.reviewsCount,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.distanceInKm,
    this.availableTime,
    this.schedule = const {},
  });

  final String id;
  final String name;
  final String? specialty;
  final String? address;
  final double? rating;
  final int? reviewsCount;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceInKm;
  final String? availableTime;
  final Map<String, dynamic> schedule;
}
