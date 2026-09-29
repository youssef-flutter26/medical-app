import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/home/data/models/medical_center_model.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

void main() {
  group('MedicalCenterModel tests', () {
    test('toFirestore returns map with required numbers and fields', () {
      final model = MedicalCenterModel(
        name: 'Sunrise Health Clinic',
        address: '123 Oak Street, CA 98765',
        rating: 4.9,
        reviewsCount: 58,
        distance: '2.5 km',
        duration: '40 min',
        type: 'Hospital',
        imagePath: 'assets/images/clinic1.png',
        createdAt: DateTime(2026, 1, 1),
      );

      final map = model.toFirestore();

      expect(map['name'], 'Sunrise Health Clinic');
      expect(map['address'], '123 Oak Street, CA 98765');
      expect(map['rating'], 4.9);
      expect(map['rating'], isA<double>());
      expect(map['reviewsCount'], 58);
      expect(map['reviewsCount'], isA<int>());
      expect(map['distance'], 2.5);
      expect(map['distance'], isA<double>());
      expect(map['duration'], 40);
      expect(map['duration'], isA<int>());
      expect(map['type'], 'Hospital');
      expect(map['imagePath'], 'assets/images/clinic1.png');
      expect(map['createdAt'], isNotNull);
    });

    test('toFirestore without createdAt returns only the 8 required fields', () {
      const model = MedicalCenterModel(
        name: 'Sunrise Health Clinic',
        address: '123 Oak Street, CA 98765',
        rating: 4.6,
        reviewsCount: 58,
        distance: '2.5 km',
        duration: '40 min',
        type: 'Hospital',
        imagePath: 'assets/images/clinic1.png',
      );

      final map = model.toFirestore();

      expect(map.keys.length, 8);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map['name'], 'Sunrise Health Clinic');
      expect(map['address'], '123 Oak Street, CA 98765');
      expect(map['rating'], 4.6);
      expect(map['reviewsCount'], 58);
      expect(map['distance'], 2.5);
      expect(map['duration'], 40);
      expect(map['type'], 'Hospital');
      expect(map['imagePath'], 'assets/images/clinic1.png');
    });

    test('fromFirestore parses Firestore map with numbers correctly', () {
      final json = <String, dynamic>{
        'name': 'Sunrise Health Clinic',
        'address': '123 Oak Street, CA 98765',
        'rating': 4.9,
        'reviewsCount': 58,
        'distance': 2.5,
        'duration': 40,
        'type': 'Hospital',
        'imagePath': 'assets/images/clinic1.png',
      };

      final model = MedicalCenterModel.fromFirestore(json, 'center_123');

      expect(model.id, 'center_123');
      expect(model.name, 'Sunrise Health Clinic');
      expect(model.address, '123 Oak Street, CA 98765');
      expect(model.rating, 4.9);
      expect(model.reviewsCount, 58);
      expect(model.distance, '2.5 km');
      expect(model.duration, '40 min');
      expect(model.type, 'Hospital');
      expect(model.imagePath, 'assets/images/clinic1.png');
    });

    test('fromFirestore parses legacy Firestore map with strings correctly', () {
      final json = <String, dynamic>{
        'name': 'Sunrise Health Clinic',
        'address': '123 Oak Street, CA 98765',
        'rating': 4.9,
        'reviewsCount': 58,
        'distance': '2.5 km',
        'duration': '40 min',
        'type': 'Hospital',
        'imagePath': 'assets/images/clinic1.png',
      };

      final model = MedicalCenterModel.fromFirestore(json, 'center_123');

      expect(model.id, 'center_123');
      expect(model.distance, '2.5 km');
      expect(model.duration, '40 min');
    });

    test('fromEntity converts entity to model', () {
      const entity = MedicalCenterEntity(
        id: 'id1',
        name: 'Alpha Clinic',
        address: 'Main St',
        rating: 4.5,
        reviewsCount: 20,
        distance: '1 km',
        duration: '10 min',
        type: 'Clinic',
        imagePath: 'assets/images/clinic2.png',
      );

      final model = MedicalCenterModel.fromEntity(entity);

      expect(model.id, 'id1');
      expect(model.name, 'Alpha Clinic');
      expect(model.type, 'Clinic');
      expect(model.rating, 4.5);
      expect(model.reviewsCount, 20);
    });
  });
}
