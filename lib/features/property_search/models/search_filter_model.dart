import 'location_model.dart';

class SearchFilterModel {
  final LocationModel? location;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int guest;
  final int child;
  final int infant;
  final int rooms;
  final double? minPrice;
  final double? maxPrice;
  final bool? instantBooking;
  final double? minRating;
  final int? bedroom;
  final int? beds;
  final int? bathroom;
  final String? query;
  final int page;
  final int perPage;

  SearchFilterModel({
    this.location,
    this.fromDate,
    this.toDate,
    this.guest = 2,
    this.child = 0,
    this.infant = 0,
    this.rooms = 1,
    this.minPrice,
    this.maxPrice,
    this.instantBooking,
    this.minRating,
    this.bedroom,
    this.beds,
    this.bathroom,
    this.query,
    this.page = 1,
    this.perPage = 20,
  });

  SearchFilterModel copyWith({
    LocationModel? location,
    DateTime? fromDate,
    DateTime? toDate,
    int? guest,
    int? child,
    int? infant,
    int? rooms,
    double? minPrice,
    double? maxPrice,
    bool? instantBooking,
    double? minRating,
    int? bedroom,
    int? beds,
    int? bathroom,
    String? query,
    int? page,
    int? perPage,
  }) {
    return SearchFilterModel(
      location: location ?? this.location,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      guest: guest ?? this.guest,
      child: child ?? this.child,
      infant: infant ?? this.infant,
      rooms: rooms ?? this.rooms,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      instantBooking: instantBooking ?? this.instantBooking,
      minRating: minRating ?? this.minRating,
      bedroom: bedroom ?? this.bedroom,
      beds: beds ?? this.beds,
      bathroom: bathroom ?? this.bathroom,
      query: query ?? this.query,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (location != null) {
      if (location!.id > 0) {
        params['location_id'] = location!.id.toString();
      }
      if (location!.lat != 0.0 || location!.lng != 0.0) {
        params['location'] = '${location!.lng}, ${location!.lat}';
      }
      if (location!.name.isNotEmpty) {
        params['address_name'] = location!.name;
      }
      params['within'] = location!.within.toString();
      params['tier_1'] = location!.tier1.toString();
      params['tier_2'] = location!.tier2.toString();
    }

    if (fromDate != null) {
      params['from'] = '${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}';
    }
    if (toDate != null) {
      params['to'] = '${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}';
    }

    params['guest'] = guest.toString();
    if (child > 0) params['child'] = child.toString();
    if (infant > 0) params['infant'] = infant.toString();
    params['rooms'] = rooms.toString();

    if (minPrice != null || maxPrice != null) {
      final minStr = minPrice != null ? minPrice!.toInt().toString() : '0';
      final maxStr = maxPrice != null ? maxPrice!.toInt().toString() : '100000';
      params['price'] = '$minStr-$maxStr';
    }

    if (instantBooking == true) {
      params['instant_booking'] = 'true';
    }

    if (minRating != null) {
      params['min_rating'] = minRating.toString();
    }

    if (bedroom != null) params['bedroom'] = bedroom.toString();
    if (beds != null) params['beds'] = beds.toString();
    if (bathroom != null) params['bathroom'] = bathroom.toString();
    if (query != null && query!.trim().isNotEmpty) params['q'] = query!.trim();

    params['page'] = page.toString();
    params['per_page'] = perPage.toString();

    return params;
  }
}
