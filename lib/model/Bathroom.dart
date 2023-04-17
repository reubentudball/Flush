
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Review.dart';

class Bathroom{

  late String title;
  late String directions;
  late LatLng location;
  late List<Review> reviews;
  late List<String> comments;


  Bathroom(this.title,this.directions, this.location);

}
