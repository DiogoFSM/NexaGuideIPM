import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';
import 'package:nexaguide_ipm/database/model/event.dart';
import 'package:nexaguide_ipm/database/model/poi.dart';
import 'package:nexaguide_ipm/CollectionItemDetailPage.dart';
import 'package:nexaguide_ipm/eventsPage.dart';
import 'package:nexaguide_ipm/location/locationSinglePage.dart';
import 'package:nexaguide_ipm/text_styles/TextStyleGillMT.dart';


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
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No events saved', style: GillMT.lighter(18)));
                }
                return ListView(
                  children: snapshot.data!.map((event) => EventCard(event: event, collection: widget.collection, onItemRemoved: refreshCollection)).toList(),
                );
            } else {
              return Text('No events found', style: GillMT.lighter(18));
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
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No locations saved', style: GillMT.lighter(18)));
                }
                return ListView(
                  children: snapshot.data!.map((poi) => POICard(poi: poi, collection: widget.collection, onItemRemoved: refreshCollection,)).toList(),
                );
            } else {
              return Text('No locations found', style: GillMT.lighter(18));
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
        title: Text(widget.collection.name, style: GillMT.title(22)),
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
    // Call your method to remove the event from the collection
    await NexaGuideDB().deleteEventFromCollection(event.id, collection.id);
    collection.eventIds.remove(event.id); // Update the collection object
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event removed from collection')),
    );
    onItemRemoved(); // Refresh the collection page
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    // Show a confirmation dialog before deletion
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion', style: GillMT.title(20)),
          content: Text('Are you sure you want to remove this event from the collection?', style: GillMT.normal(18)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GillMT.normal(18)),
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels the operation
              },
            ),
            TextButton(
              child: Text('Delete', style: GillMT.normal(18)),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms the deletion
              },
            ),
          ],
        );
      },
    ) ?? false; // Handle null (when dialog is dismissed)

    if (confirm) {
      await _removeEventFromCollection(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.event, size: 36),
        title: Text(event.name, style: GillMT.title(18)),
        subtitle: Text(event.description ?? '', style: GillMT.normal(16), maxLines: 4, overflow: TextOverflow.ellipsis,),
        onTap: () {
          // Navigate to eventsPage and pass the event ID to show its details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  eventsPage(
                    events: [event],
                    // Pass a list containing only the tapped event or modify as needed
                    initialEventId: event.id, // Pass the event ID
                  ),
            ),
          );
        },
    trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(context),
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
    // Call your method to remove the POI from the collection
    await NexaGuideDB().deletePOIFromCollection(poi.id, collection.id);
    collection.poiIds.remove(poi.id); // Update the collection object
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location removed from collection')),
    );
    onItemRemoved(); // Refresh the collection page
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    // Show a confirmation dialog before deletion
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion', style: GillMT.title(20)),
          content: Text('Are you sure you want to remove this location from the collection?', style: GillMT.normal(18)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GillMT.normal(18)),
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels the operation
              },
            ),
            TextButton(
              child: Text('Delete', style: GillMT.normal(18)),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms the deletion
              },
            ),
          ],
        );
      },
    ) ?? false; // Handle null (when dialog is dismissed)

    if (confirm) {
      await _removePOIFromCollection(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.pin_drop, size: 36),
        title: Text(poi.name, style: GillMT.title(18)),
        subtitle: Text(poi.cityName ?? '', style: GillMT.normal(16)),
        onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => LocationSinglePage(
            location: poi,
          ),
          ),
            );
        },
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ),
    );
  }
}
