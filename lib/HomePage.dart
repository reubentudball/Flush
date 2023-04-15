import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'SearchPage.dart';
import 'TagBathroomPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;

  List<Marker> _markers = [];

  Position? _currentPosition;

  final LatLng _center = const LatLng(50, -120);

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Flush', textAlign: TextAlign.center);


  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
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
          body: Center(

              child: CircularProgressIndicator()
          )

      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: customSearchBar,
          elevation: 2,
        ),
        body: GoogleMap(
          markers: Set.from(_markers),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
                _currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
          onTap: _handleTap,

        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(right: 50),
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SearchPage()));
                },
                backgroundColor: Colors.blue,

                child: const Icon(Icons.search)
            )
        ),
      );
    }
  }

  _handleTap(LatLng pos){
    setState(() {
      _markers = [];
      _markers.add(
        Marker(markerId: MarkerId(pos.toString()),
          position: pos,
          onTap: () {
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(content: Text("Would you like to add a bathroom at this location?"),
              actions: [
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TagBathroomPage()));
                }, child: Text("Ok")),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                },child: Text("No Thanks"))

              ]);
            });
          }
        )
      );
    });
  }


}
