import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/model/poi.dart';
import '../database/nexaguide_db.dart';
import 'locationMarker.dart';

class MapWidget extends StatefulWidget {
  final double initLat;
  final double initLng;
  final double initZoom;
  final double initRotation;
  final MapController mapController = MapController();
  static final NexaGuideDB database = NexaGuideDB();

  MapWidget({Key? key, required this.initLat, required this.initLng, required this.initZoom, required this.initRotation}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();

  void moveMapTo(double lat, double lng, double zoom) {
    print("Moving to: lat: $lat; lng: $lng; zoom: $zoom");
    mapController.move(LatLng(lat, lng), zoom);
  }

  Future<List<POI>> getVisiblePOIs() async {
    List<POI> list = [];
    var mapBounds = mapController.camera.visibleBounds;
    list = await database.fetchPOIByCoordinates(mapBounds.south, mapBounds.north, mapBounds.west, mapBounds.east);
    return list;
  }

}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> markers = [];
  List<POI> visiblePOIs = [];

  // We don't want to load too many markers on the map at the same time.
  // If the area visible on the map is too big, we don't want to load markers
  // TODO: Maybe "cluster" markers together instead of hiding
  // This parameter (in degrees of lat/lng) controls how big the area has to be to hide the markers
  static double markerLoadThreshold = 0.35;

  Future<void> updateVisiblePOIs() async {
    List<POI> l = [];
    var mapBounds = widget.mapController.camera.visibleBounds;
    if (!visibleAreaTooBig()) {
      l = await MapWidget.database.fetchPOIByCoordinates(mapBounds.south, mapBounds.north, mapBounds.west, mapBounds.east);
    }
    visiblePOIs = l;
  }

  /*
  void updateBoundsAndMarkers() {
    widget.updateBoundsCallback(widget.mapController.camera.visibleBounds).then((_) {
      setState(() {
        markers = widget.getMarkers();
      });
    });
  }
   */

  void updateBoundsAndMarkers() {
    updateVisiblePOIs().then((_) {
      setState(() {
        markers = getMarkers();
      });
    });
  }

  List<Marker> getMarkers() {
    List<Marker> markers = [];
    for (POI p in visiblePOIs) {
      markers.add(Marker(
        point: LatLng(p.lat, p.lng),
        rotate: true,
        alignment: Alignment.topCenter,
        child: LocationMarker(location: p),
      )
      );
    }
    print("No. of Markers: ${markers.length}");
    return markers;
  }

  bool visibleAreaTooBig() {
    var mapBounds = widget.mapController.camera.visibleBounds;
    return (mapBounds.north - mapBounds.south) >= markerLoadThreshold || (mapBounds.east - mapBounds.west) >= markerLoadThreshold/2;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.initLat, widget.initLng),
        initialZoom: widget.initZoom,
        initialRotation: widget.initRotation,
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
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }

}
