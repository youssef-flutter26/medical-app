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

  @override
  List<Object?> get props => [id, title, description, imagePath, createdAt];
}
