import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RatingsPage extends StatefulWidget{
  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Rate Bathroom"),
      ),
      body: SingleChildScrollView(
        child: Text("Review Page lol"),
      )
    );
  }
}
