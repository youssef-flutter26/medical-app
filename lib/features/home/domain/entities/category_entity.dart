class CategoryEntity {
  final String? id;
  final String name;
  final String imagePath;
  final DateTime? createdAt;

  const CategoryEntity({
    this.id,
    required this.name,
    this.imagePath = '',
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryEntity &&
        other.id == id &&
        other.name == name &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode => Object.hash(id, name, imagePath);
}
