import 'package:flush/ReviewPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const List<String> sortBy = <String>['Nearest', 'Most Clean', 'Most Quiet', 'Most Accessible'];


class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Bathroom"),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
              padding: const EdgeInsets.only(left: 20),


            child :TextField(
              decoration: InputDecoration(
                hintText: 'Search for location',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
            ),
            SortingDropDown(),

          ],
        )

      ),

    );
  }
}

class SortingDropDown extends StatefulWidget{
  const SortingDropDown({super.key});

  @override
  _SortingDropDownState createState() => _SortingDropDownState();
}

class _SortingDropDownState extends State<SortingDropDown>{
  String defaultValue = sortBy.first;

  @override
  Widget build(BuildContext context){
    return DropdownButton<String>(
      value: defaultValue,
      icon: const Icon(Icons.sort),

      onChanged: (String? value) {
        setState(() {
          defaultValue = value!;
        });
      },
      items: sortBy.map<DropdownMenuItem<String>>((String value){
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value)
        );
      }).toList(),
    );
  }
}
