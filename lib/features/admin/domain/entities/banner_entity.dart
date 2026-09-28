class BannerEntity {
  final String? id;
  final String title;
  final String description;
  final String imagePath;

  const BannerEntity({
    this.id,
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
