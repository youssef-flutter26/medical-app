import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    super.id,
    required super.title,
    required super.description,
    required super.imagePath,
    super.createdAt,
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
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
    );
  }
}
