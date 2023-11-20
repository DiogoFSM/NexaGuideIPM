import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';
import 'package:nexaguide_ipm/database/model/event.dart';
import 'package:nexaguide_ipm/database/model/poi.dart';
import 'package:nexaguide_ipm/CollectionItemDetailPage.dart';
import 'package:nexaguide_ipm/eventsPage.dart';
import 'package:nexaguide_ipm/location/locationSinglePage.dart';


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

  void refreshCollection() {
    setState(() {
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1: // Events tab
        return FutureBuilder<List<Event>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.map((event) => EventCard(event: event, collection: widget.collection, onItemRemoved: refreshCollection)).toList(),
              );
            } else {
              return Text('No events found');
            }
          },
        );
      case 0: // Locations tab
        return FutureBuilder<List<POI>>(
          future: _pois,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.map((poi) => POICard(poi: poi, collection: widget.collection, onItemRemoved: refreshCollection,)).toList(),
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
  final VoidCallback onItemRemoved;

  EventCard({Key? key, required this.event, required this.collection, required this.onItemRemoved}) : super(key: key);

  Future<void> _removeEventFromCollection(BuildContext context) async {
    await NexaGuideDB().deleteEventFromCollection(event.id, collection.id);

    // Update the collection object
    collection.eventIds.remove(event.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event removed from collection')),
    );

    onItemRemoved(); // Refresh the collection page
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.event),
        title: Text(event.name),
        subtitle: Text(event.description ?? ''),
        onTap: () { /* Existing onTap logic */ },
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            await _removeEventFromCollection(context);
            onItemRemoved(); // Call the refresh function after deletion
          },
        ),
      ),
    );
  }
}

class POICard extends StatelessWidget {
  final POI poi;
  final Collection collection;

  final VoidCallback onItemRemoved;

  POICard({Key? key, required this.poi, required this.collection, required this.onItemRemoved}) : super(key: key);

  Future<void> _removePOIFromCollection(BuildContext context) async {
    await NexaGuideDB().deletePOIFromCollection(poi.id, collection.id);

    // Update the collection object
    collection.poiIds.remove(poi.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location removed from collection')),
    );

    onItemRemoved(); // Refresh the collection page
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.pin_drop),
        title: Text(poi.name),
        subtitle: Text(poi.cityName ?? ''),
        onTap: () { /* Existing onTap logic */ },
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            await _removePOIFromCollection(context);
            onItemRemoved(); // Call the refresh function after deletion
          },
        ),
      ),
    );
  }
}
