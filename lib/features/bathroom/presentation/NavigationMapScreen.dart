import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/service/DirectionsService.dart';
import '../../../core/secrets.dart';

class NavigationMapScreen extends StatefulWidget {
  final LatLng currentPosition;
  final LatLng bathroomLocation;

  const NavigationMapScreen({
    Key? key,
    required this.currentPosition,
    required this.bathroomLocation,
  }) : super(key: key);

  @override
  _NavigationMapScreenState createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  late GoogleMapController mapController;
  final List<Marker> _markers = [];
  List<LatLng> polylineCoordinates = [];
  String? duration;
  String? distance;
  Position? _currentPosition;

  final DirectionsService _directionsService =
  DirectionsService(Secrets.directionsKey);

  @override
  void initState() {
    super.initState();
    _currentPosition = Position(
      latitude: widget.currentPosition.latitude,
      longitude: widget.currentPosition.longitude,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0, altitudeAccuracy: 0, headingAccuracy: 0,
    ); // Initial position
    _addMarkers();
    _fetchRoute();
    _startLocationUpdates();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addMarkers() {
    _markers.addAll([

      Marker(
        markerId: const MarkerId("bathroom_location"),
        position: widget.bathroomLocation,
        infoWindow: const InfoWindow(title: "Bathroom"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    ]);
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null) return;

    final routeData = await _directionsService.fetchRoute(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      widget.bathroomLocation,
    );

    if (routeData != null) {
      final polylinePoints = routeData['polyline'];
      setState(() {
        polylineCoordinates = decodePolyline(polylinePoints);
        duration = routeData['duration'];
        distance = routeData['distance'];
      });
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateCurrentLocationMarker();
        _fetchRoute();
      });
    });
  }

  void _updateCurrentLocationMarker() {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == "current_location");
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("On Foot Navigation"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.currentPosition.latitude + widget.bathroomLocation.latitude) / 2,
                (widget.currentPosition.longitude + widget.bathroomLocation.longitude) / 2,
              ),
              zoom: 15,
            ),
            markers: Set.from(_markers),
            polylines: {
              if (polylineCoordinates.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.blue,
                  width: 5,
                ),
            },
            myLocationEnabled: true,
          ),
          if (duration != null && distance != null)
            Positioned(
              top: 10,
              left: 10,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "ETA: $duration, Distance: $distance",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
