import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';
import './SearchPage.dart';
import './BathroomDetails.dart';
import './TagBathroomPage.dart';
import './QrCodeScanner.dart';
import '../../auth/controllers/UserController.dart';
import '../../auth/controllers/AuthController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  BitmapDescriptor? customMarker;
  Position? _currentPosition;
  final bathroomRepo = Get.put(BathroomRepository());
  final userController = Get.put(UserController());
  List<Bathroom> _bathrooms = [];
  final List<Marker> _tagMarkers = [];
  final Set<Circle> _circles = {};
  double _searchRadius = 0.5; // Radius in kilometers
  bool isTagging = false;
  bool showVerified = true;
  bool showUnverified = true;

  BitmapDescriptor verifiedMarkerIcon =
  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor unverifiedMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor newBathroomMarker =
  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _updateSearchRadiusCircle();
      });

      _fetchNearbyBathrooms();
    } catch (e) {
      debugPrint("Error getting current position: $e");
    }
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchNearbyBathrooms() async {
    if (_currentPosition == null) return;

    try {
      final GeoFirePoint center = GeoFirePoint(
        GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
      );

      final bathrooms = await bathroomRepo.fetchNearbyBathrooms(
        center: center,
        radiusInKm: _searchRadius,
      );

      setState(() {
        _bathrooms = bathrooms;
        _updateMarkers();
      });
    } catch (e) {
      debugPrint("Error fetching nearby bathrooms: $e");
    }
  }

  void _updateMarkers() {
    _tagMarkers.clear();

    for (Bathroom bathroom in _bathrooms) {
      if ((bathroom.isVerified && showVerified) ||
          (!bathroom.isVerified && showUnverified)) {
        _tagMarkers.add(
          Marker(
            markerId: MarkerId(bathroom.id ?? ""),
            position: bathroom.location,
            icon: bathroom.isVerified
                ? verifiedMarkerIcon
                : unverifiedMarkerIcon,
            infoWindow: InfoWindow(
              title: bathroom.title,
              snippet: bathroom.directions,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BathroomDetails(bathroom: bathroom),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    setState(() {});
  }

  void _updateSearchRadiusCircle() {
    if (_currentPosition == null) return;

    _circles.clear();

    _circles.add(
      Circle(
        circleId: const CircleId("search_radius"),
        center: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        radius: _searchRadius * 1000,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );

    setState(() {});
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services.'),
      ));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are denied'),
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Location permissions are permanently denied, we cannot request permissions.',
        ),
      ));
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bathroom Map', textAlign: TextAlign.center),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Obx(() {
            final userController = Get.find<UserController>();
            final firstName = userController.getFirstName();
            return Text("Welcome $firstName!");
          }),
          centerTitle: true,
          actions: [
            PopupMenuButton<double>(
              onSelected: (value) {
                setState(() {
                  _searchRadius = value;
                  _updateSearchRadiusCircle();
                  _fetchNearbyBathrooms();
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 0.5,
                  child: Text("Search within 0.5 km"),
                ),
                const PopupMenuItem(
                  value: 1.0,
                  child: Text("Search within 1 km"),
                ),
                const PopupMenuItem(
                  value: 5.0,
                  child: Text("Search within 5 km"),
                ),
                const PopupMenuItem(
                  value: 10.0,
                  child: Text("Search within 10 km"),
                ),
              ],
              icon: const Icon(Icons.filter_alt),
            ),
            IconButton(
              onPressed: () async {
                await _getCurrentPosition();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location and bathrooms refreshed!')),
                );
              },
              icon: const Icon(Icons.refresh),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "settings") {
                  Get.toNamed('/profile');
                } else if (value == "logout") {
                  final authConn = Get.find<AuthController>();
                  authConn.signOut();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "settings",
                  child: Text("Settings"),
                ),
                const PopupMenuItem(
                  value: "logout",
                  child: Text("Logout"),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              markers: Set.from(_tagMarkers),
              circles: _circles, // Add circles to the map
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15,
              ),
              onTap: _handleTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text("Verified"),
                    selected: showVerified,
                    onSelected: (value) {
                      setState(() {
                        showVerified = value;
                        _updateMarkers();
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text("Unverified"),
                    selected: showUnverified,
                    onSelected: (value) {
                      setState(() {
                        showUnverified = value;
                        _updateMarkers();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'search',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPage(
                      currentPosition: _currentPosition!,
                      bathrooms: _bathrooms,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.search),
              label: const Text("Search"),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'qrscanner',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrCodeScanner(
                      currentPosition: _currentPosition!,
                      bathrooms: _bathrooms,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan QR"),
            ),
          ],
        ),
      );
    }
  }

  void _handleTap(LatLng pos) {
    if (isTagging) {
      _tagMarkers.removeLast();
    }

    setState(() {
      _tagMarkers.add(
        Marker(
          markerId: MarkerId(pos.toString()),
          position: pos,
          icon: customMarker ?? newBathroomMarker,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: const Text("Would you like to add a bathroom at this location?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TagBathroomPage(location: pos)),
                        );
                      },
                      child: const Text("Ok"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          isTagging = false;
                          _tagMarkers.removeLast();
                        });
                      },
                      child: const Text("No Thanks"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
      isTagging = true;
    });
  }
}
