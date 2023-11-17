import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nexaguide_ipm/main.dart';

class MapWidget extends StatefulWidget {
  final double initLat;
  final double initLng;
  final MapBoundsCallback updateBoundsCallback;
  final MapMarkersCallback getMarkers;
  final MapController mapController = MapController();
  MapWidget({Key? key, required this.initLat, required this.initLng, required this.updateBoundsCallback, required this.getMarkers}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> markers = [];

  void updateBoundsAndMarkers() {
    widget.updateBoundsCallback(widget.mapController.camera.visibleBounds).then((_) {
      setState(() {
        markers = widget.getMarkers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.initLat, widget.initLng),
        initialZoom: 16.0,
        onMapReady: () {
          updateBoundsAndMarkers();
        },
        onPositionChanged: (MapPosition pos, bool hasGesture) {
          if (!hasGesture) {
            updateBoundsAndMarkers();
          }
        },
        onMapEvent: (MapEvent e) {
          if (e is MapEventMoveEnd) {
            updateBoundsAndMarkers();
            /*
            widget.updateBoundsCallback(widget.mapController.camera.visibleBounds).then((_) {
              setState(() {
                markers = widget.getMarkers();
              });
            });
             */
          }
        }
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: markers,
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

}
