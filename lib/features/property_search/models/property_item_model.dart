class PropertyImage {
  final int id;
  final String url;

  PropertyImage({required this.id, required this.url});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }
}

class FeaturedBadge {
  final int? id;
  final String? name;
  final String? slug;
  final String? icon;

  FeaturedBadge({this.id, this.name, this.slug, this.icon});

  factory FeaturedBadge.fromJson(Map<String, dynamic> json) {
    return FeaturedBadge(
      id: json['id'] is int ? json['id'] : null,
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}

class PropertyItemModel {
  final int id;
  final String title;
  final String address;
  final num price;
  final num? offerPrice;
  final double? reviewsAvg;
  final int reviewsCount;
  final bool isHotel;
  final List<PropertyImage> images;
  final FeaturedBadge? featuredBadge;
  final int bedroom;
  final int beds;
  final num bathroom;
  final int maxGuest;
  final String? placeType;
  final String? propertyTypeName;

  PropertyItemModel({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    this.offerPrice,
    this.reviewsAvg,
    this.reviewsCount = 0,
    this.isHotel = false,
    required this.images,
    this.featuredBadge,
    this.bedroom = 1,
    this.beds = 1,
    this.bathroom = 1,
    this.maxGuest = 2,
    this.placeType,
    this.propertyTypeName,
  });

  factory PropertyItemModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final parsedImages = rawImages
        .whereType<Map<String, dynamic>>()
        .map((e) => PropertyImage.fromJson(e))
        .toList();

    return PropertyItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Property',
      address: json['address']?.toString() ?? '',
      price: json['price'] as num? ?? 0,
      offerPrice: json['offer_price'] as num?,
      reviewsAvg: (json['reviews_avg'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] is int ? json['reviews_count'] : int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      isHotel: json['is_hotel'] is bool ? json['is_hotel'] : (json['is_hotel'] == 1),
      images: parsedImages,
      featuredBadge: json['featured_badge'] != null ? FeaturedBadge.fromJson(json['featured_badge'] as Map<String, dynamic>) : null,
      bedroom: json['bedroom'] is int ? json['bedroom'] : int.tryParse(json['bedroom']?.toString() ?? '1') ?? 1,
      beds: json['beds'] is int ? json['beds'] : int.tryParse(json['beds']?.toString() ?? '1') ?? 1,
      bathroom: json['bathroom'] as num? ?? 1,
      maxGuest: json['max_guest'] is int ? json['max_guest'] : int.tryParse(json['max_guest']?.toString() ?? '2') ?? 2,
      placeType: json['place_type']?.toString(),
      propertyTypeName: json['property_type'] != null ? json['property_type']['name']?.toString() : null,
    );
  }

  String get primaryImageUrl {
    if (images.isNotEmpty) {
      return images.first.url;
    }
    return '';
  }

  num get effectivePrice => offerPrice ?? price;
}
