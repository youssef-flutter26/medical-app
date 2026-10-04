import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';

void main() {
  group('DoctorEntity', () {
    test('supports value equality', () {
      final now = DateTime(2026, 1, 1);
      final doctor1 = DoctorEntity(
        id: '1',
        name: 'Dr. John Doe',
        specialty: 'Cardiologist',
        categoryId: 'cat1',
        categoryName: 'Cardiology',
        rating: 4.8,
        reviewsCount: 150,
        imagePath: 'assets/images/doctor1.png',
        createdAt: now,
      );

      final doctor2 = DoctorEntity(
        id: '1',
        name: 'Dr. John Doe',
        specialty: 'Cardiologist',
        categoryId: 'cat1',
        categoryName: 'Cardiology',
        rating: 4.8,
        reviewsCount: 150,
        imagePath: 'assets/images/doctor1.png',
        createdAt: now,
      );

      expect(doctor1, equals(doctor2));
      expect(doctor1.hashCode, equals(doctor2.hashCode));
    });
  });
}
