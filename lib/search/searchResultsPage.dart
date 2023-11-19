import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../appBar.dart';
import '../database/model/poi.dart';
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

  POI p = POI(id: 1, name: 'FCT NOVA', lat: 38.66098, lng: -9.20443, tags: ['University'], cityName:'Almada', description: "Universidade Nova de Lisboa - Faculdade de Ciências e Tecnologia") ; // TODO: Just for testing, Delete later
  List<POI> locations = [];

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

    locations = [p, p, p, p, p];
  }

  int get pageCount => (locations.length / locationsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NexaGuideAppBar(mapController: map.mapController),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    //child: Text("some text"),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pageCount,
                      itemBuilder: (context, pageIndex) {
                        int startIndex = pageIndex * locationsPerPage;
                        int endIndex = startIndex + locationsPerPage;
                        List<POI> pagePOI = locations.sublist(startIndex, endIndex > locations.length ? locations.length : endIndex);
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    flex:1,
                    child: map,
                  ),
                ],
              ),
            )
          )
        ],
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
              (index) => Padding(
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
    );
  }

}

class POIGridItem extends StatelessWidget {
  final POI poi;
  POIGridItem({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    String poiPrice = (poi.price != null && poi.price! > 0) ? "${poi.price!} €" : "Free";

    return TapRegion(
      onTapInside: (e) {
        print(e);
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
                                  textAlign: TextAlign.justify,
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
    );
  }
}