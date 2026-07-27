class LocationModel {
  final int id;
  final String name;
  final String? nameBn;
  final int order;
  final double lat;
  final double lng;
  final double within;
  final double tier1;
  final double tier2;

  LocationModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.order = 0,
    required this.lat,
    required this.lng,
    this.within = 10.0,
    this.tier1 = 1.0,
    this.tier2 = 5.0,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      nameBn: json['name_bn']?.toString(),
      order: json['order'] is int ? json['order'] : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      within: (json['within'] as num?)?.toDouble() ?? 10.0,
      tier1: (json['tier_1'] as num?)?.toDouble() ?? 1.0,
      tier2: (json['tier_2'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_bn': nameBn,
    'order': order,
    'lat': lat,
    'lng': lng,
    'within': within,
    'tier_1': tier1,
    'tier_2': tier2,
  };
}
