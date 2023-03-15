import 'package:flush/RestroomPage.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget{
    @override
    _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Page"),
      ),
      body: SingleChildScrollView(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search for location',
            hintStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 50),
          child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RestroomPage()));
                },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.forward)


          )


    ),
    );
  }

}
