import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/doctor/data/models/doctor_model.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';

void main() {
  group('DoctorModel', () {
    test('fromFirestore creates model correctly from JSON with Timestamp', () {
      final now = DateTime(2026, 1, 1);
      final json = <String, dynamic>{
        'name': 'Dr. Sarah Connor',
        'specialty': 'Pediatrician',
        'categoryId': 'cat_ped',
        'categoryName': 'Pediatrics',
        'experience': '8',
        'rating': '4.9',
        'reviewsCount': '230',
        'about': 'Passionate about children healthcare.',
        'imagePath': 'assets/images/doctor2.png',
        'createdAt': Timestamp.fromDate(now),
      };

      final model = DoctorModel.fromFirestore(json, 'doc123');

      expect(model.id, 'doc123');
      expect(model.name, 'Dr. Sarah Connor');
      expect(model.specialty, 'Pediatrician');
      expect(model.categoryId, 'cat_ped');
      expect(model.categoryName, 'Pediatrics');
      expect(model.experience, 8);
      expect(model.rating, 4.9);
      expect(model.reviewsCount, 230);
      expect(model.about, 'Passionate about children healthcare.');
      expect(model.imagePath, 'assets/images/doctor2.png');
      expect(model.createdAt, now);
    });

    test('toFirestore returns correct map', () {
      final now = DateTime(2026, 1, 1);
      final model = DoctorModel(
        id: 'doc1',
        name: 'Dr. Jane',
        specialty: 'Dermatologist',
        categoryId: 'cat_derm',
        categoryName: 'Dermatology',
        experience: 5,
        rating: 4.5,
        reviewsCount: 80,
        about: 'Expert skin care specialist.',
        imagePath: 'assets/images/doctor3.png',
        createdAt: now,
      );

      final data = model.toFirestore();

      expect(data['name'], 'Dr. Jane');
      expect(data['specialty'], 'Dermatologist');
      expect(data['categoryId'], 'cat_derm');
      expect(data['categoryName'], 'Dermatology');
      expect(data['experience'], 5);
      expect(data['rating'], 4.5);
      expect(data['reviewsCount'], 80);
      expect(data['about'], 'Expert skin care specialist.');
      expect(data['imagePath'], 'assets/images/doctor3.png');
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('fromEntity converts DoctorEntity to DoctorModel', () {
      final entity = DoctorEntity(
        id: 'doc99',
        name: 'Dr. Strange',
        specialty: 'Neurosurgeon',
        categoryId: 'cat_neuro',
        categoryName: 'Neurology',
        experience: 15,
        rating: 5.0,
        reviewsCount: 1000,
        about: 'Master of the mystic arts and surgery.',
        imagePath: 'assets/images/doctor_strange.png',
      );

      final model = DoctorModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.specialty, entity.specialty);
      expect(model.categoryId, entity.categoryId);
      expect(model.categoryName, entity.categoryName);
      expect(model.experience, entity.experience);
      expect(model.rating, entity.rating);
      expect(model.reviewsCount, entity.reviewsCount);
      expect(model.about, entity.about);
      expect(model.imagePath, entity.imagePath);
    });
  });
}
