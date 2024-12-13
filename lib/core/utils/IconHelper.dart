import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconHelper {
  static IconData getBathroomTypeIcon(String type) {
    switch (type) {
      case "Men's":
        return Icons.male;
      case "Women's":
        return Icons.female;
      case "Family":
        return Icons.family_restroom;
      case "Unisex":
        return Icons.wc;
      default:
        return Icons.bathroom;
    }
  }

  static IconData getAccessTypeIcon(String accessType) {
    switch (accessType.toLowerCase()) {
      case "public":
        return Icons.public;
      case "private":
        return Icons.lock;
      case "business":
        return Icons.business_center;
      default:
        return Icons.help_outline;
    }
  }
}
