import 'package:flutter/material.dart';

import '../database/model/poi.dart';
import 'locationPopup.dart';

class LocationMarker extends StatefulWidget {
  final POI location;

  const LocationMarker({super.key, required this.location});

  @override
  State<LocationMarker> createState() => _LocationMarkerState();
}

class _LocationMarkerState extends State<LocationMarker> {
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry(context) {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;


    var locationPopup = TapRegion(
      onTapOutside: (e) {
        setState(() {
          hideOverlay();
        });
      },
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: LocationPopup(
            location: widget.location,
            closePopup: hideOverlay,
          ),
        ),
      ),
    );

    double offsetTop = offset.dy <= height/2 ? offset.dy + 10 : offset.dy - 270;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offsetTop,
        child: locationPopup
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
    return IconButton(
        icon: const Icon(Icons.location_pin),
        onPressed: () {
          _overlayEntry?.remove();
          showOverlay();
        },
        iconSize: 36,
      );
  }
}