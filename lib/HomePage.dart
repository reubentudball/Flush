
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flush/QrCodeScanner.dart';
import 'package:flush/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';





import 'BathroomDetails.dart';
import 'ReviewPage.dart';
import 'SearchPage.dart';
import 'TagBathroomPage.dart';

import 'package:get/get.dart';



import 'model/Bathroom.dart';
import 'model/BathroomRepo.dart';



class HomePage extends StatefulWidget {




  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;

  Position? _currentPosition;

  final bathroomRepo = Get.put(BathroomRepository());
  List<Bathroom> _bathrooms = [];

  final user = FirebaseAuth.instance.currentUser!;

  final List<Marker> _tagMarkers = [];
  var isTagging = false;

  Icon customIcon = const Icon(Icons.search);
  BitmapDescriptor customMarker = BitmapDescriptor.defaultMarker;
  Widget customSearchBar = const Text('Bathroom Map', textAlign: TextAlign.center);


  @override
  void initState() {

    super.initState();
    _getCurrentPosition();
    addCustomIcon();
    _getBathrooms();
  }


  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(10,10)), "asset/images/addmarker.bmp")
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
    for(Bathroom bathroom in _bathrooms){

      _tagMarkers.add(Marker(
          markerId: MarkerId(bathroom.location.toString()),
          position: bathroom.location,
          onTap: (){
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(

                title: Text(bathroom.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text("Directions: ${bathroom.directions}"),

                  ],
                ),
                actions: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        BathroomDetails(bathroom: bathroom)));
                  },
                      child: const Text("See Details")),
                  ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>ReviewPage(bathroom: bathroom)));
                  }, child: const Text("Review")),
                  TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Close"))
                ],
              );
            });
          }
      ));
    }

    Future.delayed(const Duration(seconds: 1)).then((value) => setState((){}));
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
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
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
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
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
          centerTitle: true,
          title: customSearchBar,
          elevation: 2,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: customSearchBar,
          elevation: 2,
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
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(title: ''),
                    ),
                  );
                },
                child: Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
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
                child: const Icon(Icons.search),
              ),
              SizedBox(width: 30),
              ElevatedButton(
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
                child: Text('Scan QR Code'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),
            ],
          ),
        ),
      );
    }
  }
  _handleTap(LatLng pos){
    if (isTagging){
      _tagMarkers.removeLast();
    }

    setState(() {
      _tagMarkers.add(
          Marker(markerId: MarkerId(pos.toString()),
              position: pos,
              icon: customMarker,
              onTap: () {
                showDialog(context: context, builder: (BuildContext context){
                  return AlertDialog(content: const Text("Would you like to add a bathroom at this location?"),
                      actions: [
                        TextButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TagBathroomPage(location: pos)));
                        }, child: const Text("Ok")),
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                          setState(() {
                            isTagging = false;
                            _tagMarkers.removeLast();
                          });
                        },child: const Text("No Thanks"))

                      ]);
                });
              }
          )
      );
      isTagging = true;
    });
  }
}
