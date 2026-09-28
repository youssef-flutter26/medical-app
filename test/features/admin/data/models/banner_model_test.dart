import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/features/admin/data/models/banner_model.dart';

void main() {
  group('BannerModel tests', () {
    test('toFirestore returns correct map', () {
      const model = BannerModel(
        title: 'Special Offer',
        description: '50% off dental checkup',
        imageUrl: 'https://example.com/banner.png',
      );

      final map = model.toFirestore();

      expect(map, {
        'title': 'Special Offer',
        'description': '50% off dental checkup',
        'imageUrl': 'https://example.com/banner.png',
      });
    });

    test('fromFirestore parses map correctly', () {
      final map = {
        'title': 'Checkup Discount',
        'description': 'Valid until next week',
        'imageUrl': 'https://example.com/promo.png',
      };

      final model = BannerModel.fromFirestore(map, 'doc_123');

      expect(model.id, 'doc_123');
      expect(model.title, 'Checkup Discount');
      expect(model.description, 'Valid until next week');
      expect(model.imageUrl, 'https://example.com/promo.png');
    });
  });
}
