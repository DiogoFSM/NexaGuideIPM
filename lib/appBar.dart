import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nexaguide_ipm/search/searchResultsPage.dart';
import 'database/model/city.dart';
import 'database/model/poi.dart';
import 'database/nexaguide_db.dart';
import 'filterPage.dart';

typedef MoveMapCallback = void Function(double lat, double lng, double zoom);

class NexaGuideAppBar extends StatefulWidget {
  //final MoveMapCallback onSuggestionPress;
  final MapController mapController;
  final void Function(MapController m) onSearchButtonPress;

  //const NexaGuideAppBar({super.key, required this.onSuggestionPress});
  const NexaGuideAppBar({super.key, required this.mapController, required this.onSearchButtonPress});

  @override
  State<StatefulWidget> createState() => _NexaGuideAppBarState();
}

class _NexaGuideAppBarState extends State<NexaGuideAppBar> {
  OverlayEntry? _overlayEntry;
  final TextEditingController _controller = TextEditingController();
  late LocationSearchDelegate _delegate;

  void moveMapTo(double lat, double lng, double zoom) {
    print("Moving to: lat: $lat; lng: $lng; zoom: $zoom");
    widget.mapController.move(LatLng(lat, lng), zoom);
    //mapBounds = mapController.camera.visibleBounds;
  }

  @override
  void initState() {
    super.initState();
    _delegate = LocationSearchDelegate(onSuggestionPress: moveMapTo, hideOverlay: hideOverlay, searchBarController: _controller);
  }

  OverlayEntry _createOverlayEntry(context) {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    var suggestions = TapRegion(
        onTapOutside: (e) {
          hideOverlay();
        },
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white38,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Colors.black54,
                    width: 2.0,
                  ),
                ),
              ),
              child: _delegate.buildSuggestions(context),
            ),
          ),
        ),


    );

    return OverlayEntry(
      builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: Container(
            height: 150,
            //color: Colors.red,
            child: TapRegion(
              onTapOutside: (e) {
                hideOverlay();
              },
              child: suggestions,
            ),
          ),
      ),
    );
  }

  void showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry = _createOverlayEntry(context);
    overlay.insert(_overlayEntry!);
  }

  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }


  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      _delegate.query = _controller.text;
    });

    return AppBar(
      //automaticallyImplyLeading: false,
      leading: Navigator.of(context).canPop() ?
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          iconSize: 28,
        )
      : InkWell(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/nexaguide3.png'),
          ),
      ),
      actions: [
        /*
        Flexible(
          flex: 1,
          child: IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.menu_rounded),
            iconSize: 28,
          ),
        ),
         */

        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextField(
              controller: _controller,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontFamily: 'GillSansMT', fontSize: 19),
              decoration: InputDecoration(
                hintText: 'Search...',
                //hintStyle: TextStyle(color: Colors.black54, fontFamily: 'GillSansMT',),
                border: OutlineInputBorder(),
                //suffixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.onSearchButtonPress(widget.mapController);
                    /*
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchResultsPage(
                      initLat: widget.mapController.camera.center.latitude,
                      initLng: widget.mapController.camera.center.longitude,
                      initZoom: widget.mapController.camera.zoom,
                      initRotation: widget.mapController.camera.rotation,
                    )));
                     */
                  },
                  icon: Icon(Icons.search),
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
              onChanged: (search) {
                _overlayEntry?.remove();
                showOverlay();
              },
              onTap: () {
                showOverlay();
              },
              onSubmitted: (search) {
                //_controller.clear();
                hideOverlay();
              },
            ),
          ),
        ),

        Flexible(
            flex: 1,
            child: FilterPage()
        ),

        Flexible(
          flex: 1,
          child: IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.account_circle),
            iconSize: 28,
          ),
        ),
    ]);
  }
}

class LocationSearchDelegate extends SearchDelegate {
  final MoveMapCallback onSuggestionPress;
  final void Function() hideOverlay;
  final TextEditingController searchBarController;
  LocationSearchDelegate({required this.onSuggestionPress, required this.searchBarController, required this.hideOverlay});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<City>>(
      future: NexaGuideDB().searchCities(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<City> matchQuery = snapshot.data!;
          return ListView.builder(
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return ListTile(
                title: Text(result.name),
                subtitle: Text(result.country),
              );
            },
          );
        }
        else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text("Search for a place...",
          style: TextStyle(
            inherit: false,
            color: Colors.black54,
            fontFamily: 'GillSansMT',
            fontSize: 20
          )
        ),
      );
    }
    return FutureBuilder<List<City>>(
      future: NexaGuideDB().searchCities(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<City> matchQuery = snapshot.data!;
          if (matchQuery.isEmpty) {
            return const Center(
              child: Text("No results.",
                style: TextStyle(
                  inherit: false,
                  color: Colors.black54,
                  fontFamily: 'GillSansMT',
                  fontSize: 20
                )
              ),
            );
          }
          return ListView.builder(
            itemCount: matchQuery.length,
            itemExtent: 60,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(result.name, style: TextStyle(fontFamily: 'GillSansMT', fontSize: 19)),
                  subtitle: Text(result.country, style: TextStyle(fontFamily: 'GillSansMT', fontSize: 15)),
                  trailing: Text("(id: ${result.id})", style: TextStyle(fontFamily: 'GillSansMT', fontSize: 15)),
                  onTap: () {
                    searchBarController.text = result.name;
                    hideOverlay();
                    onSuggestionPress(result.lat, result.lng, 13.0);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              );
            },
          );
        }
        else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
