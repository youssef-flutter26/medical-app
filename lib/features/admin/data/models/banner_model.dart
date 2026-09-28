import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    super.id,
    required super.title,
    required super.description,
    required super.imagePath,
  });

  factory BannerModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    return BannerModel(
      id: docId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: (json['imagePath'] as String?) ??
          (json['imageUrl'] as String?) ??
          '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
    };
  }
}
