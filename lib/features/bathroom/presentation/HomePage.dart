import 'package:firebase_auth/firebase_auth.dart';
import 'package:flush/features/bathroom/presentation/QrCodeScanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flush/features/auth/presentation/LoginPage.dart';
import 'BathroomDetails.dart';
import './ReviewPage.dart';
import './SearchPage.dart';
import 'TagBathroomPage.dart';
import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  final bathroomRepo = Get.put(BathroomRepository());
  List<Bathroom> _bathrooms = [];
  final List<Marker> _tagMarkers = [];
  var isTagging = false;

  BitmapDescriptor customMarker = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    addCustomIcon();
    _getBathrooms();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(10, 10)), "asset/images/addmarker.bmp")
        .then(
          (icon) {
        setState(() {
          customMarker = icon;
        });
      },
    );
  }

  void _getBathrooms() async {
    _bathrooms = await bathroomRepo.getAllBathrooms();
    for (Bathroom bathroom in _bathrooms) {
      _tagMarkers.add(
        Marker(
          markerId: MarkerId(bathroom.location.toString()),
          position: bathroom.location,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(bathroom.title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text("Directions: ${bathroom.directions}")],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BathroomDetails(bathroom: bathroom),
                          ),
                        );
                      },
                      child: const Text("See Details"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewPage(bathroom: bathroom),
                          ),
                        );
                      },
                      child: const Text("Review"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
    }
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      debugPrint(e);
    });
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
          title: const Text('Bathroom Map', textAlign: TextAlign.center),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              markers: Set.from(_tagMarkers),
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15,
              ),
              onTap: _handleTap,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          icon: customMarker,
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
