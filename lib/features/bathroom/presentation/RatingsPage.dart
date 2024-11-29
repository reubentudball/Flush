import 'package:flutter/material.dart';

class RatingsPage extends StatefulWidget{
  const RatingsPage({super.key});

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Bathroom"),
      ),
      body: const SingleChildScrollView(
        child: Text("Review Page"),
      )
    );
  }
}
