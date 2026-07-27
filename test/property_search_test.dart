import 'package:flutter_test/flutter_test.dart';
import 'package:travela_search_screen/features/property_search/models/location_model.dart';
import 'package:travela_search_screen/features/property_search/models/property_item_model.dart';
import 'package:travela_search_screen/features/property_search/models/search_filter_model.dart';
import 'package:travela_search_screen/features/property_search/services/property_search_service.dart';

void main() {
  group('Property Search Models Test', () {
    test('LocationModel parses correctly', () {
      final json = {
        'id': 42,
        'name': "Cox's Bazar",
        'name_bn': 'কক্সবাজার',
        'order': 1,
        'lat': 21.4272,
        'lng': 92.0058,
        'within': 15.0,
        'tier_1': 5.0,
        'tier_2': 10.0,
      };
      final model = LocationModel.fromJson(json);
      expect(model.id, equals(42));
      expect(model.name, equals("Cox's Bazar"));
      expect(model.nameBn, equals('কক্সবাজার'));
      expect(model.lat, equals(21.4272));
      expect(model.lng, equals(92.0058));
    });

    test('PropertyItemModel parses item SSE frame correctly', () {
      final json = {
        'id': 501,
        'title': 'Sea View Studio',
        'address': "Kolatoli, Cox's Bazar",
        'price': 3200,
        'offer_price': 2800,
        'reviews_avg': 4.7,
        'reviews_count': 38,
        'is_hotel': false,
        'images': [
          {'id': 9, 'url': 'https://example.com/a.jpg'}
        ],
        'featured_badge': {'id': 1, 'name': 'Guest Favourite', 'slug': 'guest_favourite'},
        'bedroom': 1,
        'beds': 2,
        'bathroom': 1,
        'max_guest': 3
      };
      final item = PropertyItemModel.fromJson(json);
      expect(item.id, equals(501));
      expect(item.title, equals('Sea View Studio'));
      expect(item.price, equals(3200));
      expect(item.offerPrice, equals(2800));
      expect(item.effectivePrice, equals(2800));
      expect(item.reviewsAvg, equals(4.7));
      expect(item.images.length, equals(1));
      expect(item.primaryImageUrl, equals('https://example.com/a.jpg'));
    });

    test('SearchFilterModel converts to query params correctly', () {
      final location = LocationModel(
        id: 42,
        name: "Cox's Bazar",
        lat: 21.4272,
        lng: 92.0058,
      );
      final filter = SearchFilterModel(
        location: location,
        guest: 2,
        fromDate: DateTime(2026, 9, 26),
        toDate: DateTime(2026, 9, 28),
      );
      final queryParams = filter.toQueryParams();

      expect(queryParams['location_id'], equals('42'));
      expect(queryParams['guest'], equals('2'));
      expect(queryParams['from'], equals('2026-09-26'));
      expect(queryParams['to'], equals('2026-09-28'));
    });
  });

  group('Live API & Stream Test', () {
    test('fetchPopularLocations returns results from live endpoint', () async {
      final service = PropertySearchService();
      final locations = await service.fetchPopularLocations(query: 'cox');
      expect(locations, isNotEmpty);
      expect(locations.first.name.toLowerCase(), contains('cox'));
    });
  });
}
