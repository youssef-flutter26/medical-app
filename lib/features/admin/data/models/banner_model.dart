import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
  });

  factory BannerModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    return BannerModel(
      id: docId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
