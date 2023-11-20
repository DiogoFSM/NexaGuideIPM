import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nexaguide_ipm/Review/Review.dart';
import 'package:nexaguide_ipm/database/database_service.dart';
import 'package:nexaguide_ipm/login.dart';
import 'package:nexaguide_ipm/map/map.dart';
import 'package:nexaguide_ipm/search/searchResultsPage.dart';
import 'package:sqflite/sqflite.dart';

import 'Menu.dart';
import 'appBar.dart';
import 'database/model/city.dart';
import 'database/model/event.dart';
import 'database/model/poi.dart';
import 'database/nexaguide_db.dart';
import 'map/locationMarker.dart';
import 'map/locationPopup.dart';
import 'eventsPage.dart';
import 'collectionsPage.dart';

typedef MoveMapCallback = void Function(double lat, double lng, double zoom);
typedef MapBoundsCallback = Future<void> Function(LatLngBounds bounds);
typedef MapMarkersCallback = List<Marker> Function();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
      home:  MenuScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  //final String title;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarVisible = false;

  void openDrawer() {
    print("openDrawer called");
    _scaffoldKey.currentState?.openDrawer();
  }

  void toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }
  late MapWidget map;

  Map<String, dynamic> filters = {
    'minPrice': 0,
    'maxPrice': 200,
    'minRating': 0,
    'maxRating': 5,
    'distance': 0.0,
    'tags':List<String>.empty()
  };

  @override
  void initState() {
    super.initState();

    map = MapWidget(initLat: initLat, initLng: initLng, initZoom: initZoom, initRotation: 0.0, getFilters: () {return filters;},);
  }

  // TODO: just for testing, remove later
  Future<List<Event>> _getPOIEvents(int poiID) async {
    List<Event> l = [];
    l = await database.fetchEventsByPOI(poiID);
    return l;
  }

  void _navigateToEventsPage() async {
    List<Event> events = await database.fetchAllEvents();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => eventsPage(events: events)),
    );
  }

  void _navigateToCollectionsPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CollectionsPage()),
    );
  }

  void _navigateToReviewsPage() {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewPage(placeName: "placeName", userName: "userName", userPhotoUrl:" userPhotoUrl")),
    );
  }
  void _navigateToLoginPage() {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
  void _navigateToMenuPage() {
    //List<Event> events = await database.fetchAllEvents();
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuScreen(),
        ));
  }

  void _navigateToSearchResultsPage(MapController m) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SearchResultsPage(
          initLat: m.camera.center.latitude,
          initLng: m.camera.center.longitude,
          initZoom: m.camera.zoom,
          initRotation: m.camera.rotation,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -2.0);
          const end = Offset(0.0, 0.0);
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);
          return Stack(
            children: [
              SlideTransition(
                position: offsetAnimation,
              ),
              FadeTransition(
                opacity: animation,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, dynamic> _applyFilters({required int minPrice, required int maxPrice, required int minRating, required int maxRating, required double distance, required List<String> tags}) {
    setState(() {
      filters = {
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'minRating': minRating,
        'maxRating': maxRating,
        'distance': distance,
        'tags': tags,
      };
    });
    //print(filters);
    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children:[
            NexaGuideAppBar(mapController: map.mapController, onSearchButtonPress: _navigateToSearchResultsPage, onFiltersApply: _applyFilters, onMenuButtonPressed: toggleSidebar, filtersApplied: filters,),
            Expanded(
                child: Stack(
                  children: [
                    map,
                    Positioned(
                      bottom: 7,
                      right: 7,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.circle
                            ),
                            child: IconButton(
                                icon: Icon(Icons.zoom_in_map_rounded, size: 28),
                                onPressed: () {
                                  _navigateToSearchResultsPage(map.mapController);
                                }
                            ),

                          ),
                        ),
                      ),
                    ),
                    if (isSidebarVisible) _buildCustomSidebar(),
                  ]
                )
            ),
            // TODO This row just contains testing options, delete or hide later
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          database.createPOIWithTagsAndImages(
                              name: 'FCT NOVA',
                              lat: 38.66098,
                              lng: -9.20443,
                              website: 'https://www.fct.unl.pt/',
                              description: "Universidade Nova de Lisboa - Faculdade de Ciências e Tecnologia",
                              tags:['Cultural'],
                              photoURLs: [
                                'https://www.fct.unl.pt/sites/default/files/imagens/noticias/2015/03/DSC_5142_Tratado.jpg',
                                'https://arquivo.codingfest.fct.unl.pt/2016/sites/www.codingfest.fct.unl.pt/files/imagens/fctnova.jpeg',
                                'https://www.fct.unl.pt/sites/default/files/imagecache/l740/imagens/noticias/2021/02/campusfct.png',
                              ],
                              cityID: 3595
                          );
                          database.createEventWithTags(name: "Semana do Caloiro", poiID: 1, dateStart: 1694563200000, dateEnd: 1694822400000, location: "Caparica", startTime: "20:00h", endTime: "04:00h", tags: ["Festival"]);
                        });
                      },
                      child: Text('Test POI')
                  ),
                ),
                Flexible(
                  child: FutureBuilder<String>(
                    future: DatabaseService().fullPath,
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            _navigateToMenuPage();                          },
                          child: Text('Menu Page')
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
                            _navigateToReviewsPage();                          },
                          child: Text('Review Page')
                      ) : Center(child: CircularProgressIndicator());
                    },
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
                Flexible(
                  child: FutureBuilder<String>(
                    future: DatabaseService().fullPath,
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ElevatedButton(
                          onPressed: () {
                            _navigateToCollectionsPage();                          },
                          child: Text('Collections Page')
                      ) : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
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
            )*/
          ]
      ),
    );
  }

  Widget _buildCustomSidebar() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: 250, // Adjust the width as needed
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        // Add your menu items here
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.menu),
              title: Text('Menu'),
              onTap: () {
                _navigateToMenuPage();
                // Handle Map navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.mic),
              title: Text('Events'),
              onTap: () {
                _navigateToEventsPage();
                // Handle Map navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.collections),
              title: Text('Collections'),
              onTap: () {
                _navigateToCollectionsPage();
                // Handle Map navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Login'),
              onTap: () {
                _navigateToLoginPage();
                // Handle Map navigation
              },
            ),
            // ... other ListTile items ...
          ],
        ),
      ),
    );
  }
}