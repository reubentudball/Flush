import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flush/features/bathroom/presentation/BathroomDetails.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';
import './SearchPage.dart';
import './TagBathroomPage.dart';
import './QrCodeScanner.dart';
import '../../auth/controllers/UserController.dart';
import '../../auth/controllers/AuthController.dart';
import '../../../core/constants.dart';
import 'ReviewPage.dart';
import  '../../../core/utils/IconHelper.dart';

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
  final List<Marker> _markers = [];
  final Set<Circle> _circles = {};
  double _searchRadius = 0.5; // Radius in kilometers
  bool isTagging = false;
  bool showVerified = true;
  bool showUnverified = true;
  String? selectedBathroomType;
  String? selectedAccessType;

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
    isTagging = false;
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
        _updateMarkersWithFilters();
      });
    } catch (e) {
      debugPrint("Error fetching nearby bathrooms: $e");
    }
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


  void _updateMarkersWithFilters({bool fetchNewBathrooms = false}) async {
    if (fetchNewBathrooms && _currentPosition != null) {
      try {
        final GeoFirePoint center = GeoFirePoint(
          GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        );

        _bathrooms = await bathroomRepo.fetchNearbyBathrooms(
          center: center,
          radiusInKm: _searchRadius,
        );
        _updateSearchRadiusCircle();
      } catch (e) {
        debugPrint("Error fetching bathrooms: $e");
        return;
      }
    }

    final filteredBathrooms = _bathrooms.where((bathroom) {
      final verifiedMatches = (bathroom.isVerified && showVerified) ||
          (!bathroom.isVerified && showUnverified);
      final typeMatches = selectedBathroomType == null || bathroom.bathroomType == selectedBathroomType;
      final accessMatches = selectedAccessType == null || bathroom.accessType == selectedAccessType?.toLowerCase();
      return verifiedMatches && typeMatches && accessMatches;
    }).toList();

    setState(() {
      _markers.clear();
      for (Bathroom bathroom in filteredBathrooms) {
        _markers.add(
          Marker(
            markerId: MarkerId(bathroom.id ?? ""),
            position: bathroom.location,
            icon: bathroom.isVerified ? verifiedMarkerIcon : unverifiedMarkerIcon,
            onTap: () => _showBathroomDetails(bathroom),
          ),
        );
      }
    });
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

  void _showBathroomDetails(Bathroom bathroom) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bathroom Title
              Text(
                bathroom.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),

              // Bathroom Directions
              Text(
                bathroom.directions,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(
                    IconHelper.getBathroomTypeIcon(bathroom.bathroomType),
                    size: 28,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bathroom.bathroomType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(IconHelper.getAccessTypeIcon(bathroom.accessType), size: 28, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    bathroom.accessType[0].toUpperCase() + bathroom.accessType.substring(1), // Holy shit this is so bad
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.health_and_safety, size: 28, color: Colors.green),
                  const SizedBox(width: 12),
                  Text(
                    "Health Score: ${bathroom.healthScore?.toStringAsFixed(1) ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BathroomDetails(bathroom: bathroom)),
                        );
                      },
                      icon: const Icon(Icons.info, size: 20),
                      label: const Text("See Details"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReviewPage(bathroom: bathroom)),
                        );
                      },
                      icon: const Icon(Icons.rate_review, size: 20),
                      label: const Text("Leave Review"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }




  void _showFilterMenu() {
    bool tempShowVerified = showVerified;
    bool tempShowUnverified = showUnverified;
    String? tempSelectedBathroomType = selectedBathroomType;
    String? tempSelectedAccessType = selectedAccessType;
    double tempSearchRadius = _searchRadius;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Filter Bathrooms"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Search Radius (km)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: tempSearchRadius,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      label: "${tempSearchRadius.toStringAsFixed(1)} km",
                      onChanged: (value) {
                        setDialogState(() {
                          tempSearchRadius = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Verified Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tempShowVerified,
                          onChanged: (value) {
                            setDialogState(() {
                              tempShowVerified = value!;
                            });
                          },
                        ),
                        const Text("Verified"),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tempShowUnverified,
                          onChanged: (value) {
                            setDialogState(() {
                              tempShowUnverified = value!;
                            });
                          },
                        ),
                        const Text("Unverified"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Bathroom Type",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: tempSelectedBathroomType,
                      hint: const Text("Select Bathroom Type"),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("Any"),
                        ),
                        ...BathroomTypeConstants.bathroomTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempSelectedBathroomType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Access Type",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: tempSelectedAccessType,
                      hint: const Text("Select Access Type"),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("Any"),
                        ),
                        ...AccessTypeConstants.accessTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempSelectedAccessType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showVerified = tempShowVerified;
                      showUnverified = tempShowUnverified;
                      selectedBathroomType = tempSelectedBathroomType;
                      selectedAccessType = tempSelectedAccessType;
                      _searchRadius = tempSearchRadius;

                      _updateMarkersWithFilters(fetchNewBathrooms: true);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
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
            IconButton(
              onPressed: () async {
                await _getCurrentPosition();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location and bathrooms refreshed!')),
                );
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterMenu,
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
              markers: Set.from(_markers),
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
      _markers.removeLast();
    }

    setState(() {
      _markers.add(
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
                          _markers.removeLast();
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
