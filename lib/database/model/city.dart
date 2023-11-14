class City {
  final int id;
  final String name;
  final String country;
  final int? population;
  final double lat;
  final double lng;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.lat,
    required this.lng,
    this.population
  });

  factory City.fromSqfliteDatabase(Map<String, dynamic> map) => City(
    id: map['id']?.toInt() ?? 0,
    name: map['name'] ?? '',
    country: map['country'] ?? '',
    population: map['population']?.toInt(),
    lat: map['lat'].toDouble(),
    lng: map['lng'].toDouble()
  );

  @override
  String toString() {
    return "[$id] $name ($lat, $lng)";
  }
}