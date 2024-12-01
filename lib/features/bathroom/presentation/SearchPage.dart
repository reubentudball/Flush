import 'package:flush/features/bathroom/presentation/BathroomDetails.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';

const List<String> sortBy = <String>['Nearest', 'Most Clean', 'Most Quiet', 'Most Spacious'];

class SearchPage extends StatefulWidget {
  final Position currentPosition;
  final List<Bathroom> bathrooms;

  const SearchPage({super.key, required this.currentPosition, required this.bathrooms});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Position currentPosition;
  final bathroomRepo = Get.put(BathroomRepository());
  late List<Bathroom> bathrooms;
  String selectedSort = sortBy.first;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.currentPosition;
    bathrooms = widget.bathrooms;
    _sortBathrooms(); // Initial sorting
  }

  void _sortBathrooms() {
    setState(() {
      if (selectedSort == 'Nearest') {
        bathrooms.sort((a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));
      } else if (selectedSort == 'Most Clean') {
        bathrooms.sort((a, b) => b.cleanlinessScore!.compareTo(a.cleanlinessScore!));
      } else if (selectedSort == 'Most Quiet') {
        bathrooms.sort((a, b) => b.trafficScore!.compareTo(a.trafficScore!));
      } else if (selectedSort == 'Most Spacious') {
        bathrooms.sort((a, b) => b.sizeScore!.compareTo(a.sizeScore!));
      }
    });
  }

  double _calculateDistance(Bathroom bathroom) {
    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      bathroom.location.latitude,
      bathroom.location.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Bathroom"),
      ),
      body: Column(
        children: [
          // Search Bar and Sorting
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search for location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      setState(() {
                        bathrooms = widget.bathrooms
                            .where((bathroom) =>
                        bathroom.title.toLowerCase().contains(query.toLowerCase()) ||
                            bathroom.directions.toLowerCase().contains(query.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SortingDropDown(
                  selectedSort: selectedSort,
                  onSortChanged: (newSort) {
                    setState(() {
                      selectedSort = newSort;
                      _sortBathrooms();
                    });
                  },
                ),
              ],
            ),
          ),
          // Bathroom List
          Expanded(
            child: bathrooms.isEmpty
                ? const Center(
              child: Text(
                "No bathrooms found.",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: bathrooms.length,
              itemBuilder: (context, index) {
                final bathroom = bathrooms[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bathroom.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Directions: ${bathroom.directions}"),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Distance: ${(_calculateDistance(bathroom) / 1000).toStringAsFixed(2)} km",
                              style: const TextStyle(color: Colors.grey),
                            ),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SortingDropDown extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortChanged;

  const SortingDropDown({super.key, required this.selectedSort, required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedSort,
      icon: const Icon(Icons.sort),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onSortChanged(newValue);
        }
      },
      items: sortBy.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
