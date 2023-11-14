import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nexaguide_ipm/map/map.dart';
import 'package:latlong2/latlong.dart';

import 'appBar.dart';
import 'database/model/city.dart';
import 'database/nexaguide_db.dart';

typedef MoveMapCallback = void Function(double lat, double lng, double zoom);

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,

      ),
      home: const MyHomePage(title: 'NexaGuide Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = NexaGuideDB();

  static double initLat = 38.66098;
  static double initLng = -9.20443;
  MapWidget map = MapWidget(lat: initLat, lng: initLng);

  void _moveMapTo(double lat, double lng, double zoom) {
    print("Received: lat: $lat; lng: $lng; zoom: $zoom");
    MapController mapController = map.mapController;
    mapController.move(LatLng(lat, lng), zoom);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
                        database.fetchCityById(1);
                      });
                    },
                    child: Text('Just testing')
                ),
                FutureBuilder<List<City>> (
                  future: database.fetchAllCities(),
                  builder: (context, snapshot) {
                    return snapshot.hasData ?
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            print("something");
                            snapshot.data?.forEach((city) {print(city);});
                          });
                        },
                        child: Text('Just testing 2')
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
