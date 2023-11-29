import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';
import 'package:nexaguide_ipm/database/model/event.dart';
import 'package:nexaguide_ipm/database/model/poi.dart';
import 'package:nexaguide_ipm/CollectionItemDetailPage.dart';
import 'package:nexaguide_ipm/eventsPage.dart';
import 'package:nexaguide_ipm/location/locationSinglePage.dart';
import 'package:nexaguide_ipm/text_styles/TextStyleGillMT.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Review/Review.dart';
import 'collectionsPage.dart';


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

  Future<void> _addReview(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(placeName: event.name, userName: username, userPhotoUrl: "null"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not logged in'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                  children: snapshot.data!.map((event) => EventCard(
                      event: event,
                      collection: widget.collection,
                      onItemRemoved: refreshCollection,
                      onBookmark: (eventId, collectionId) {
                        NexaGuideDB().addEventToCollection(eventId, collectionId).then((_) {
                          // Handle success, maybe show a snackbar message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Event added to collection')),
                          );
                        }).catchError((e) {
                          // Handle error, maybe show a snackbar message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add event to collection')),
                          );
                        });
                      },
                      onAddReview: () => _addReview(event),
                  )).toList(),
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
  final DateFormat format = DateFormat('dd/MM/yyyy');
  final Function(int eventId, int collectionId) onBookmark;
  final VoidCallback onAddReview;

  EventCard({Key? key, required this.event, required this.collection, required this.onItemRemoved, required this.onBookmark, required this.onAddReview}) : super(key: key);

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

  void _showEventDetailsDialog(BuildContext context) {
    String dateStart = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateStart).toLocal());
    String dateEnd = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateEnd).toLocal());
    String dateText = dateStart == dateEnd ? dateStart : '$dateStart - $dateEnd';
    String priceText = (event.price != null && event.price! > 0) ? "${event.price!} €" : "Free";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView( // To ensure the dialog is scrollable if content is too long
            child: ListBody(
              children: <Widget>[
                Text(
                  event.name,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GillSansMT'
                  ),
                ),
                const Divider(
                  color: Colors.black26,
                  thickness: 2,
                ),
                Text('• Location:  ${event.location}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                // TODO: Talvez meter o sitio (POI) onde o evento decorre??
                SizedBox(height: 8),
                Text('• Time:  ${event.startTime} - ${event.endTime}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                //Text('Data: ${event.dateStart} - ${event.dateEnd}'),
                Text('• Date:  $dateText', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                Text('• Price:  $priceText', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                Text('• Website:  ${event.website}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    // TODO: Trocar para iconButton
                    Icon(Icons.pin_drop_rounded, color: Colors.orange, size: 36),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.bookmark_add_outlined, color: Colors.orange, size: 36),
                      onPressed: () async {
                        // Open the collections page and await the selected collection
                        final selectedCollectionId = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionsPage(selectMode: true),
                          ),
                        );
                        // If a collection was selected, call the callback to add the event to the collection
                        if (selectedCollectionId != null) {
                          onBookmark(event.id, selectedCollectionId);
                        }
                      },
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.star_outline_rounded, color: Colors.orange, size: 36),
                      onPressed: onAddReview, // Call the provided callback function
                    ),                // Add more icons as needed
                  ],
                ),
                SizedBox(height: 8),
                // TODO: Adicionar tags
                Text('${event.description}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)), // Replace with actual description
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17, color: Colors.orange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.event, size: 36),
        title: Text(event.name, style: GillMT.title(18)),
        subtitle: Text(event.description ?? '', style: GillMT.normal(16), maxLines: 4, overflow: TextOverflow.ellipsis,),
        onTap: () => _showEventDetailsDialog(context),
        /*
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
        */
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
