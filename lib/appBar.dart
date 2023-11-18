import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database/model/city.dart';
import 'database/nexaguide_db.dart';
import 'main.dart';

// TODO: Profile/Menu buttons

class NexaGuideAppBar extends StatefulWidget {
  const NexaGuideAppBar({super.key, required this.onSuggestionPress});

  final MoveMapCallback onSuggestionPress;

  @override
  State<StatefulWidget> createState() => _NexaGuideAppBarState();
}

class _NexaGuideAppBarState extends State<NexaGuideAppBar> {
  OverlayEntry? _overlayEntry;
  final TextEditingController _controller = TextEditingController();
  late LocationSearchDelegate _delegate;

  @override
  void initState() {
    super.initState();
    _delegate = LocationSearchDelegate(onSuggestionPress: widget.onSuggestionPress, hideOverlay: hideOverlay, searchBarController: _controller);
  }

  OverlayEntry _createOverlayEntry(context) {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    var suggestions = TapRegion(
        onTapOutside: (e) {
          hideOverlay();
        },
        child: _delegate.buildSuggestions(context),
    );

    return OverlayEntry(
      builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: Container(
            height: 150,
            color: Colors.white,
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

    return AppBar(actions: [
      Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: () {
                  // do something
                },
                child: Ink.image(
                  image: AssetImage('assets/nexaguide3.png'),
                  fit: BoxFit.scaleDown,
                  width: 40,
                  height: 40,
                  child: InkWell(
                    splashColor: Colors.black.withOpacity(0.5),
                    highlightColor: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: TextField(
                controller: _controller,
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(fontFamily: 'GillSansMT', fontSize: 19),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  //hintStyle: TextStyle(color: Colors.black54, fontFamily: 'GillSansMT',),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
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
          ],
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
      return Container(
        child: Center(
          child: Text("Search for a place...",
              style: TextStyle(
                  inherit: false,
                  color: Colors.black54,
                  fontFamily: 'GillSansMT',
                  fontSize: 20
              )
          ),
        ),
      );
    }
    return FutureBuilder<List<City>>(
      future: NexaGuideDB().searchCities(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<City> matchQuery = snapshot.data!;
          if (matchQuery.isEmpty) {
            return Container(
              child: Center(
                child: Text("No results.",
                  style: TextStyle(
                    inherit: false,
                    color: Colors.black54,
                    fontFamily: 'GillSansMT',
                    fontSize: 20
                  )
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: matchQuery.length,
            itemExtent: 60,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return Material(
                child: ListTile(
                  title: Text(result.name, style: TextStyle(fontFamily: 'GillSansMT', fontSize: 19)),
                  subtitle: Text(result.country, style: TextStyle(fontFamily: 'GillSansMT', fontSize: 15)),
                  onTap: () {
                    searchBarController.text = result.name;
                    hideOverlay();
                    onSuggestionPress(result.lat, result.lng, 13.0);
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
