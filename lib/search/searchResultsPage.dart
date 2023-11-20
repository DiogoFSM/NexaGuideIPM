import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nexaguide_ipm/main.dart';

import '../appBar.dart';
import '../database/model/poi.dart';
import '../database/nexaguide_db.dart';
import '../location/locationSinglePage.dart';
import '../map/map.dart';

class SearchResultsPage extends StatefulWidget {

  final double initLat;
  final double initLng;
  final double initZoom;
  final double initRotation;

  const SearchResultsPage({super.key, required this.initLat, required this.initLng, required this.initZoom, required this.initRotation});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  static int locationsPerPage = 4;
  late MapWidget map;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<POI> locations = [];
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
    map = MapWidget(initLat: widget.initLat, initLng: widget.initLng, initZoom: widget.initZoom, initRotation: widget.initRotation,);

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });

    getLocations();
  }

  int get pageCount => (locations.length / locationsPerPage).ceil();
  
  Future<List<POI>> getLocations() async {
    //locations = await NexaGuideDB().fetchPOIByCoordinates(-90, 90, -180, 180);
    //print(filters);

    locations = await NexaGuideDB().searchPOI(
      minPrice: filters['minPrice'] >= 1 ? filters['minPrice'] as int : null,
      maxPrice: filters['maxPrice'] as int,
      tags: filters['tags'] as List<String>,
    );
    return locations;
  }

  void _searchButtonPress(MapController m) {
    // Do something
  }

  void _applyFilters({required int minPrice, required int maxPrice, required int minRating, required int maxRating, required double distance, required List<String> tags}) {
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NexaGuideAppBar(mapController: map.mapController, onSearchButtonPress: _searchButtonPress, onFiltersApply: _applyFilters, onMenuButtonPressed: () {  }, filtersApplied: filters,),
          FutureBuilder(
            future: getLocations(),
            builder: (context, snapshot) {
              //if (snapshot.hasData) print(pageCount);
              return snapshot.hasData ?
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: pageCount,
                          itemBuilder: (context, pageIndex) {
                            int startIndex = pageIndex * locationsPerPage;
                            int endIndex = startIndex + locationsPerPage;
                            List<POI> pagePOI = locations.sublist(startIndex, endIndex > locations.length ? locations.length : endIndex);
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.1, // Adjust the aspect ratio as needed
                              ),
                              itemCount: pagePOI.length,
                              itemBuilder: (context, index) {
                                return POIGridItem(poi: pagePOI[index]);
                              },
                            );
                          },
                        ),
                      ),

                      _buildPageIndicator(),

                      Expanded(
                        flex:2,
                        child: Container(
                          padding: EdgeInsets.all(10),
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
                                            icon: Icon(Icons.zoom_out_map_outlined, size: 28),
                                            onPressed: () {
                                              if(Navigator.of(context).canPop()) {
                                                Navigator.of(context).pop();
                                              }
                                              else {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (context) => MyHomePage(),)
                                                );
                                              }
                                            }
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]
                          )
                        ),
                      ),

                    ],
                  ),
                )

              : SizedBox(
                  width: 200,
                  height: 200,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color:Colors.orange)
                  )
              );
            },
          ),
        ]
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(
          pageCount,
              (index) => Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.orange : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class POIGridItem extends StatelessWidget {
  final POI poi;
  POIGridItem({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    String poiPrice = (poi.price != null) ? (poi.price! > 0 ? "${poi.price!} €" : "Free") : '???';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.orange,
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LocationSinglePage (location: poi)));
        },
        child: Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          width: 300.0,
          height: 224.0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black45,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible (
                flex: 1,
                child: Text(
                  poi.name,
                  style: const TextStyle(
                    inherit: false,
                    color: Colors.black,
                    fontFamily: 'GillSansMT',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),

              const Divider(
                color: Colors.black26,
                thickness: 2,
              ),

              Flexible(
                  flex: 3,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 2,
                            child: Column (
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "City:  ${poi.cityName}\nPrice:  $poiPrice",
                                    style: const TextStyle(
                                      inherit: false,
                                      color: Colors.black,
                                      fontFamily: 'GillSansMT',
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                            flex: 1,
                            child: Column (
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                      "4.5", // TODO Replace with actual average value of reviews
                                      style: const TextStyle(
                                        fontFamily: 'GillSansMT',
                                        fontSize: 16,
                                      ),
                                    ),
                                ),

                                const Flexible(
                                  flex: 2,
                                  child: Icon(Icons.star_outline_rounded, size: 40, color: Colors.orange,)
                                ),
                              ],
                            )
                        )
                      ]
                  )
              ),

              Expanded(
                flex: 1,
                child: Text(
                  poi.tags.toString(),
                  style: const TextStyle(
                    inherit: false,
                    color: Colors.black,
                    fontFamily: 'GillSansMT',
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}