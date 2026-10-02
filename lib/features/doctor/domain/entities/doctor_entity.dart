class DoctorEntity {
  final String? id;
  final String name;
  final String specialty;
  final String categoryId;
  final String categoryName;
  final int experience;
  final double rating;
  final int reviewsCount;
  final String about;
  final String imagePath;
  final DateTime? createdAt;

  const DoctorEntity({
    this.id,
    required this.name,
    required this.specialty,
    required this.categoryId,
    required this.categoryName,
    required this.experience,
    required this.rating,
    required this.reviewsCount,
    required this.about,
    required this.imagePath,
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
        other.experience == experience &&
        other.rating == rating &&
        other.reviewsCount == reviewsCount &&
        other.about == about &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        specialty,
        categoryId,
        categoryName,
        experience,
        rating,
        reviewsCount,
        about,
        imagePath,
      );
}
