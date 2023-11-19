import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../appBar.dart';
import '../database/model/poi.dart';
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

  POI p = POI(id: 1, name: 'FCT NOVA', lat: 38.66098, lng: -9.20443, tags: ['University']) ; // TODO: Delete later
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
              padding: EdgeInsets.all(12),
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
                            childAspectRatio: 1.3, // Adjust the aspect ratio as needed
                          ),
                          itemCount: pagePOI.length,
                          itemBuilder: (context, index) {
                            return Text(pagePOI[index].toString());
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
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ),
      ),
    );
  }

}