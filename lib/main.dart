import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:nexaguide_ipm/map/map.dart';
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

  // Initial coordinates for the map
  // TODO: change to get current position of user
  static double initLat = 38.66098;
  static double initLng = -9.20443;
  static double initZoom = 15.0;

  late MapWidget map;

  @override
  void initState() {
    super.initState();
    map = MapWidget(initLat: initLat, initLng: initLng, initZoom: initZoom, initRotation: 0.0,);
  }

  // TODO: just for testing, remove later
  Future<List<Event>> _getPOIEvents(int poiID) async {
    List<Event> l = [];
    l = await database.fetchEventsByPOI(poiID);
    return l;
  }

  void _navigateToEventsPage() async {
    database.createEvent(name: "Nos Alive", poiID: 1, dateStart: 0, dateEnd: 200, location: "Algés", endTime: "04:00h", startTime: "18:00h", price: 45);
    List<Event> events = await database.fetchAllEvents();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => eventsPage(events: events)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children:[
            NexaGuideAppBar(mapController: map.mapController),
            Expanded(
                child: map
            ),
            // TODO This row just contains testing options, delete or hide later
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
                              tags:['University'],
                              cityID: 3595
                          );

                          database.createEventWithTags(name: "Semana do Caloiro", poiID: 1, dateStart: 1694563200000, dateEnd: 1694822400000, location: "Caparica", startTime: "20:00h", endTime: "04:00h", tags: ["Festival"]);
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
                Flexible(
                  child: FutureBuilder<String>(
                    future: DatabaseService().fullPath,
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            _navigateToEventsPage();                          },
                          child: Text('Events Page')
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