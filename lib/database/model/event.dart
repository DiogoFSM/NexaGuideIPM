class Event {
  final int id;
  final String name;
  final int dateStart;
  final int dateEnd;
  final int poiID;
  final List<String> tags;
  final String location;
  final String startTime;
  final String endTime;
  final String? website;
  final int? price;
  final String? description;

  Event({
    required this.id,
    required this.name,
    required this.dateStart,
    required this.dateEnd,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.poiID,
    required this.tags,
    this.website,
    this.price,
    this.description,
  });

  factory Event.fromSqfliteDatabase({required Map<String, dynamic> map, List<String>? tags}) => Event(
    id: map['id']?.toInt() ?? 0,
    name: map['name'] ?? '',
    location: map['location'] ?? '',
    startTime: map['startTime'] ?? '',
    endTime: map['endTime'] ?? '',
    dateStart: map['dateStart']?? 0,
    dateEnd: map['dateEnd'] ?? 0,
    poiID: map['poiID']?.toInt() ?? -1,
    tags: tags ?? [],
    website: map['website'] ?? '',
    price: map['price'] ?? -1,
    description: map['description'] ?? '',
  );

  @override
  String toString() {
    return "[$id] $name";
  }
}