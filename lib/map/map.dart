import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nexaguide_ipm/main.dart';

class MapWidget extends StatefulWidget {
  final double initLat;
  final double initLng;
  final MapBoundsCallback updateBoundsCallback;
  final MapController mapController = MapController();
  MapWidget({Key? key, required this.initLat, required this.initLng, required this.updateBoundsCallback}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.initLat, widget.initLng),
        initialZoom: 16.0,
        onMapReady: () {
          widget.updateBoundsCallback(widget.mapController.camera.visibleBounds);
        },
        onPositionChanged: (MapPosition pos, bool hasGesture) {
          if (!hasGesture) {
            widget.updateBoundsCallback(pos.bounds!);
          }
        },
        onMapEvent: (MapEvent e) {
          if (e is MapEventMoveEnd) {
            widget.updateBoundsCallback(e.camera.visibleBounds);
          }
        }
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
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
