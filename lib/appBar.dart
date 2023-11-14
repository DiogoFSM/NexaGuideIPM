import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class NexaGuideAppBar extends StatefulWidget {
  const NexaGuideAppBar({super.key, required this.onSuggestionPress});

  final MapCallback onSuggestionPress;

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
    _delegate = LocationSearchDelegate(onSuggestionPress: widget.onSuggestionPress);
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                decoration: InputDecoration(
                  hintText: 'Search...',
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
  List<String> searchTerms = ['Lisboa', 'Porto', 'Faro'];

  final MapCallback onSuggestionPress;
  LocationSearchDelegate({required this.onSuggestionPress});

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
    List<String> matchQuery = [];
    for (var x in searchTerms) {
      if (x.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(x);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    List<String> matchQuery = [];
    for (var x in searchTerms) {
      if (x.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(x);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return Material(
            child: ListTile(
              title: Text(result),
              onTap: () {
                //print(result);
                onSuggestionPress(result);
              },
        ));
      },
    );
  }
}
