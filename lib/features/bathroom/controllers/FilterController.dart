import 'package:get/get.dart';

class FilterController extends GetxController {
  var showVerified = true.obs;
  var showUnverified = true.obs;
  var selectedBathroomType = Rx<String?>(null);
  var selectedAccessType = Rx<String?>(null);
  var searchRadius = 0.5.obs;

  void resetFilters() {
    showVerified.value = true;
    showUnverified.value = true;
    selectedBathroomType.value = null;
    selectedAccessType.value = null;
    searchRadius.value = 0.5;
  }
}
