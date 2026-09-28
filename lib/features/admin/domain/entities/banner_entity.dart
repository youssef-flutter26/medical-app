class BannerEntity {
  final String? id;
  final String title;
  final String description;
  final String imageUrl;

  const BannerEntity({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
