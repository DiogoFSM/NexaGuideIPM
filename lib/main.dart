import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:nexaguide_ipm/map/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

import 'appBar.dart';
import 'database/model/city.dart';
import 'database/model/event.dart';
import 'database/model/poi.dart';
import 'database/nexaguide_db.dart';
import 'map/locationMarker.dart';
import 'map/locationPopup.dart';
import 'eventsPage.dart';

typedef MoveMapCallback = void Function(double lat, double lng, double zoom);
typedef MapBoundsCallback = Future<void> Function(LatLngBounds bounds);
typedef MapMarkersCallback = List<Marker> Function();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaGuide',
      theme: ThemeData(
        primarySwatch: Colors.orange,

      ),
      home: const MyHomePage(title: 'NexaGuide Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = NexaGuideDB();
  LatLngBounds? mapBounds;
  List<POI>? visiblePOIs;

  // Initial coordinates for the map
  // TODO: change to get current position of user
  static double initLat = 38.66098;
  static double initLng = -9.20443;

  // We don't want to load too many markers on the map at the same time.
  // If the area visible on the map is too big, we don't want to load markers
  // TODO: Maybe "cluster" markers together instead of hiding
  // This parameter (in degrees of lat/lng) controls how big the area has to be to hide the markers
  static double markerLoadThreshold = 0.25;

  late MapWidget map;

  @override
  void initState() {
    super.initState();
    map = MapWidget(initLat: initLat, initLng: initLng, getMarkers: getMarkers, updateBoundsCallback: _updateMapBounds);
  }

  // TODO: maybe these functions to move map, update visible POI, etc should be on map.dart, will see later
  void _moveMapTo(double lat, double lng, double zoom) {
    print("Received: lat: $lat; lng: $lng; zoom: $zoom");
    MapController mapController = map.mapController;
    mapController.move(LatLng(lat, lng), zoom);
    mapBounds = mapController.camera.visibleBounds;
  }

  Future<void> _updateMapBounds(LatLngBounds bounds) async {
    mapBounds = bounds;
    await _updateVisiblePOIs();
    /*
    print("${mapBounds?.south}, ${mapBounds?.north}");
    print("${mapBounds?.west}, ${mapBounds?.east}");
    print("---------------------------------------");
     */
  }

  Future<void> _updateVisiblePOIs() async {
    List<POI> l = [];
    if (mapBounds != null && !visibleAreaTooBig()) {
      l = await database.fetchPOIByCoordinates(mapBounds!.south, mapBounds!.north, mapBounds!.west, mapBounds!.east);
    }
    visiblePOIs = l;
  }

  // TODO: This function is redundant, delete later
  Future<List<POI>> _getVisiblePOIs() async {
    List<POI> l = [];
    if (mapBounds != null && !visibleAreaTooBig()) {
      l = await database.fetchPOIByCoordinates(mapBounds!.south, mapBounds!.north, mapBounds!.west, mapBounds!.east);
      //l = await database.fetchPOIByCoordinates(38.0, 39.0, -10.0, -9.0);
    }
    return l;
  }

  Future<List<Event>> _getPOIEvents(int poiID) async {
    List<Event> l = [];
    l = await database.fetchEventsByPOI(poiID);
    return l;
  }

  List<Marker> getMarkers() {
    List<Marker> markers = [];
    for (POI p in visiblePOIs!) {
      markers.add(Marker(
        point: LatLng(p.lat, p.lng),
        rotate: true,
        alignment: Alignment.topCenter,
        //child: Icon(Icons.location_pin, color:Colors.indigo, size: 50.0,), //TODO: this should be a fancier widget, that you can click, etc.
        //child: LocationPopup(location: p)
        child: LocationMarker(location: p),
        )
      );
    }
    print("No. of Markers: ${markers.length}");
    return markers;
  }

  bool visibleAreaTooBig() {
    return mapBounds != null &&
        ((mapBounds!.north - mapBounds!.south) >= markerLoadThreshold || (mapBounds!.east - mapBounds!.west) >= markerLoadThreshold/2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children:[
            NexaGuideAppBar(onSuggestionPress: _moveMapTo),
            Expanded(
                child: map
            ),
            // This row just contains testing options, delete or hide later
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          database.createPOIWithTags(
                              name: 'FCT NOVA',
                              lat: 38.66098,
                              lng: -9.20443,
                              website: 'https://www.fct.unl.pt/',
                              description: "Universidade Nova de Lisboa - Faculdade de Ciências e Tecnologia",
                              tags:['University']
                          );

                          database.createEventWithTags(name: "Semana do Caloiro", poiID: 1, dateStart: 0, dateEnd: 100, tags: ["Festival"]);
                        });
                      },
                      child: Text('Test POI')
                  ),
                ),

                Flexible(
                  child: FutureBuilder<List<Event>> (
                    future: _getPOIEvents(1),
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            snapshot.data?.forEach((event) {print("${event.name} ${event.tags}");});
                          },
                          child: Text('Print FCT Events')
                      ) : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),

                /*
                Flexible(
                  child: FutureBuilder<List<POI>> (
                    future: _getVisiblePOIs(),
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            snapshot.data?.forEach((poi) {print("$poi ${poi.tags}");});
                            /*
                            setState(() {
                              //snapshot.data?.forEach((city) {print(city);});
                              snapshot.data?.forEach((poi) {print("$poi ${poi.tags}");});
                            });
                             */
                          },
                          child: Text('Print visible POI')
                      ) : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                Flexible(
                  child: FutureBuilder<List<POI>> (
                    future: _getVisiblePOIs(),
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            // Navigate to the EventsPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => eventsPage()),
                            );
                          },
                          child: Text('Events Page')
                      ) : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                */
                // NOTE: after deleting database, it will "re-initialize" because we are getting the visible poi list
                // TODO We need to make sure the database is always initialized when the user opens the app for the first time
                Flexible(
                  child: FutureBuilder<String>(
                    future: DatabaseService().fullPath,
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              deleteDatabase(snapshot.data!);
                            });
                          },
                          child: Text('Delete Database!!!')
                      ) : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            )
          ]
      ),
    );
  }
}
