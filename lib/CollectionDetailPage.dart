import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';
import 'package:nexaguide_ipm/database/model/event.dart';
import 'package:nexaguide_ipm/database/model/poi.dart';
import 'package:nexaguide_ipm/CollectionItemDetailPage.dart';


class CollectionDetailPage extends StatefulWidget {
  final Collection collection;

  CollectionDetailPage({Key? key, required this.collection}) : super(key: key);

  @override
  _CollectionDetailPageState createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  late Future<List<Event>> _events;
  late Future<List<POI>> _pois; // Assuming POI is a model class like Event
  int _selectedIndex = 0; // 0 for events, 1 for locations

  @override
  void initState() {
    super.initState();
    _events = NexaGuideDB().fetchEventsByIds(widget.collection.eventIds);
    _pois = NexaGuideDB().fetchPoisByIds(widget.collection.poiIds); // You need to implement this method
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Events tab
        return FutureBuilder<List<Event>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.map((event) => EventCard(event: event, collection: widget.collection)).toList(),
              );
            } else {
              return Text('No events found');
            }
          },
        );
      case 1: // Locations tab
        return FutureBuilder<List<POI>>(
          future: _pois,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.map((poi) => POICard(poi: poi, collection: widget.collection)).toList(),
              );
            } else {
              return Text('No locations found');
            }
          },
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


class EventCard extends StatelessWidget {
  final Event event;
  final Collection collection;

  EventCard({Key? key, required this.event, required this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isBookmarked = collection.eventIds.contains(event.id);
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.event),
        title: Text(event.name),
        subtitle: Text(event.description ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionItemDetailPage(
                item: event,
                collectionId: collection.id,
                isBookmarked: isBookmarked,
              ),
            ),
          );
        },
      ),
    );
  }
}

class POICard extends StatelessWidget {
  final POI poi;
  final Collection collection;

  POICard({Key? key, required this.poi, required this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isBookmarked = collection.poiIds.contains(poi.id);
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.pin_drop),
        title: Text(poi.name),
        subtitle: Text(poi.cityName ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionItemDetailPage(
                item: poi,
                collectionId: collection.id,
                isBookmarked: isBookmarked,
              ),
            ),
          );
        },
      ),
    );
  }
}
