import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String imagePath;
  final DateTime? createdAt;

  const BannerEntity({
    this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.createdAt,
  });

  BannerEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, imagePath, createdAt];
}
