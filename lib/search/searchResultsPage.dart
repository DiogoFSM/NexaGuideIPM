import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../appBar.dart';
import '../map/map.dart';

class SearchResultsPage extends StatefulWidget {
  final double initLat;
  final double initLng;

  const SearchResultsPage({super.key, required this.initLat, required this.initLng});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late MapWidget map;

  @override
  void initState() {
    super.initState();
    map = MapWidget(initLat: widget.initLat, initLng: widget.initLng, getMarkers: () {return [];}, updateBoundsCallback: (a) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NexaGuideAppBar(onSuggestionPress: (a, b, c) {}),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text("Here is some text", textAlign: TextAlign.center,),
                  ),
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

}