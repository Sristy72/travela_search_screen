import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travela_search_screen/features/property_search/models/location_model.dart';
import 'package:travela_search_screen/features/property_search/models/property_item_model.dart';
import 'package:travela_search_screen/features/property_search/models/search_filter_model.dart';
import 'package:travela_search_screen/features/property_search/models/search_meta_model.dart';
import 'package:travela_search_screen/features/property_search/services/property_search_service.dart';
import 'package:travela_search_screen/features/property_search/widgets/property_card_widget.dart';

void main() {
  group('Property Search Models & Parser Tests', () {
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

    test('SearchMetaModel parses totalCount and pagination.next correctly', () {
      final json = {
        'total_count': 120,
        'filter_meta': {'min_price': 500, 'max_price': 20000},
        'pagination': {
          'current_page': 1,
          'next': 'https://search.travela.xyz/api/search/stream?page=2'
        }
      };
      final meta = SearchMetaModel.fromJson(json);
      expect(meta.totalCount, equals(120));
      expect(meta.pagination?['next'], equals('https://search.travela.xyz/api/search/stream?page=2'));
    });

    test('SseEvent holds event type and decoded data correctly', () {
      final sseEvent = SseEvent(
        event: 'meta',
        data: {'total_count': 45},
      );
      expect(sseEvent.event, equals('meta'));
      expect(sseEvent.data['total_count'], equals(45));
    });
  });

  group('Widget Tests', () {
    testWidgets('PropertyCardWidget renders property title and specs correctly', (WidgetTester tester) async {
      final property = PropertyItemModel(
        id: 99,
        title: 'Luxury Villa in Gulshan',
        address: 'Gulshan 2, Dhaka',
        price: 5000,
        bedroom: 2,
        beds: 3,
        bathroom: 2,
        reviewsAvg: 4.9,
        reviewsCount: 15,
        images: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertyCardWidget(property: property, totalDays: 2),
            ),
          ),
        ),
      );

      expect(find.text('Luxury Villa in Gulshan'), findsOneWidget);
      expect(find.text('2 Bedroom • 3 Bed • 2 Bath'), findsOneWidget);
      expect(find.text('BDT 5000 '), findsOneWidget);
      expect(find.text('Total BDT 10000'), findsOneWidget);
    });
  });
}
