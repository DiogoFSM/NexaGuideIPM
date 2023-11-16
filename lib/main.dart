import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:nexaguide_ipm/map/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

import 'appBar.dart';
import 'database/model/city.dart';
import 'database/model/poi.dart';
import 'database/nexaguide_db.dart';

typedef MoveMapCallback = void Function(double lat, double lng, double zoom);
typedef MapBoundsCallback = void Function(LatLngBounds bounds);

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

  static double initLat = 38.66098;
  static double initLng = -9.20443;

  late MapWidget map;

  @override
  void initState() {
    super.initState();
    map = MapWidget(initLat: initLat, initLng: initLng, updateBoundsCallback: _updateMapBounds);
  }

  void _moveMapTo(double lat, double lng, double zoom) {
    print("Received: lat: $lat; lng: $lng; zoom: $zoom");
    MapController mapController = map.mapController;
    mapController.move(LatLng(lat, lng), zoom);
    mapBounds = mapController.camera.visibleBounds;
  }

  void _updateMapBounds(LatLngBounds bounds) {
    setState(() {
      mapBounds = bounds;
    });

  }

  Future<List<POI>> _getVisiblePOIs() async {
    List<POI> l = [];
    if (mapBounds != null) {
      l = await database.fetchPOIByCoordinates(mapBounds!.south, mapBounds!.north, mapBounds!.west, mapBounds!.east);
      //l = await database.fetchPOIByCoordinates(38.0, 39.0, -10.0, -9.0);
    }
    return l;
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
            // This row just contains testing options, delete later
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        database.createPOIWithTags(name: 'FCT', lat: 38.66098, lng: -9.20443, website: 'https://www.fct.unl.pt/', tags:['University']);
                      });
                    },
                    child: Text('Test POI')
                ),
                FutureBuilder<List<POI>> (
                  future: _getVisiblePOIs(),
                  builder: (context, snapshot) {
                    return snapshot.hasData ?
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            //snapshot.data?.forEach((city) {print(city);});
                            snapshot.data?.forEach((poi) {print("$poi ${poi.tags}");});
                          });
                        },
                        child: Text('Print visible POI')
                    ) : Center(child: CircularProgressIndicator());
                  },
                ),
                // NOTE: after deleting database, it will "re-initialize" because we are getting the visible poi
                // We need to make sure the database is always initialized when the user opens the app for the first time
                FutureBuilder<String>(
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
              ],
            )
          ]
      ),
    );
  }
}
