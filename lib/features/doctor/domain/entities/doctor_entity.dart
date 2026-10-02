class DoctorEntity {
  final String? id;
  final String name;
  final String specialty;
  final String categoryId;
  final String categoryName;
  final String address;
  final double rating;
  final int reviewsCount;
  final String imagePath;
  final String availableTime;
  final DateTime? createdAt;

  const DoctorEntity({
    this.id,
    required this.name,
    required this.specialty,
    required this.categoryId,
    required this.categoryName,
    this.address = '',
    required this.rating,
    required this.reviewsCount,
    required this.imagePath,
    this.availableTime = 'Mon - Sat: 09:00 AM - 05:00 PM',
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorEntity &&
        other.id == id &&
        other.name == name &&
        other.specialty == specialty &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.address == address &&
        other.rating == rating &&
        other.reviewsCount == reviewsCount &&
        other.availableTime == availableTime &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode => Object.hash(
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
      );
}
