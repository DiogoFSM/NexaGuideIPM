class Collection {
  final int id;
  final String name;
  final List<int> eventIds; // List of event IDs associated with the collection
  final List<int> poiIds; // List of event IDs associated with the collection
  final int creationDate;

  Collection({required this.id, required this.name, required this.eventIds, required this.poiIds, required this.creationDate});
}
