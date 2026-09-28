import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/admin/data/models/banner_model.dart';

void main() {
  group('BannerModel tests', () {
    test('toFirestore returns correct map with imagePath', () {
      const model = BannerModel(
        title: 'Special Offer',
        description: '50% off dental checkup',
        imagePath: 'assets/images/banner1.png',
      );

      final map = model.toFirestore();

      expect(map, {
        'title': 'Special Offer',
        'description': '50% off dental checkup',
        'imagePath': 'assets/images/banner1.png',
      });
    });

    test('fromFirestore parses map with imagePath correctly', () {
      final map = {
        'title': 'Checkup Discount',
        'description': 'Valid until next week',
        'imagePath': 'assets/images/banner1.png',
      };

      final model = BannerModel.fromFirestore(map, 'doc_123');

      expect(model.id, 'doc_123');
      expect(model.title, 'Checkup Discount');
      expect(model.description, 'Valid until next week');
      expect(model.imagePath, 'assets/images/banner1.png');
    });
  });
}
