class POI {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final int? cityID;
  final List<String> tags;
  final String? address;
  final String? website;
  final int? price;
  final String? description;
  final String? cityName;

  POI({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.cityID,
    required this.tags,
    this.address,
    this.website,
    this.price,
    this.description,
    this.cityName
  });

  factory POI.fromSqfliteDatabase({required Map<String, dynamic> map, List<String>? tags}) => POI(
    id: map['id']?.toInt() ?? 0,
    name: map['name'] ?? '',
    lat: map['lat']?.toDouble() ?? 0.0,
    lng: map['lng']?.toDouble() ?? 0.0,
    cityID: map['cityID']?.toInt() ?? -1,
    tags: tags ?? [],
    address: map['address'] ?? '???',
    website: map['website'] ?? '???',
    price: map['price'] ?? -1,
    description: map['description'] ?? '',
    cityName: map['cityName'] ?? '???'
  );

  @override
  String toString() {
    return "[$id] $name ($lat, $lng)";
  }
}