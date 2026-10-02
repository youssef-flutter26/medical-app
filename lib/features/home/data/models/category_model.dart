import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    required super.name,
    super.imagePath,
    super.createdAt,
  });

  factory CategoryModel.fromFirestore(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    DateTime? parsedCreatedAt;
    final rawCreatedAt = json['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    final rawName =
        json['name'] ?? json['categoryName'] ?? json['title'] ?? '';
    final rawImage =
        json['imagePath'] ?? json['imageUrl'] ?? json['imageName'] ?? '';

    return CategoryModel(
      id: docId,
      name: rawName.toString(),
      imagePath: rawImage.toString(),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imagePath': imagePath,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : Timestamp.now(),
    };
  }
}
