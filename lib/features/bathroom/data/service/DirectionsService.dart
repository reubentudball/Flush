import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  final String apiKey;

  DirectionsService(this.apiKey);

  Future<Map<String, dynamic>?> fetchRoute(
      LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=walking&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return {
            'polyline': data['routes'][0]['overview_polyline']['points'],
            'duration': data['routes'][0]['legs'][0]['duration']['text'],
            'distance': data['routes'][0]['legs'][0]['distance']['text'],
          };
        }
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }

    return null;
  }
}
