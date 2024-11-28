import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/models/Review.dart';
import '../data/repository/BathroomRepo.dart';

class BathroomController extends GetxController {
  final BathroomRepository _repository = BathroomRepository();

  var bathrooms = <Bathroom>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBathrooms();
  }

  Future<void> fetchBathrooms() async {
    isLoading(true);
    errorMessage('');

    try {
      final data = await _repository.getAllBathrooms();
      bathrooms.value = data;
    } catch (e) {
      errorMessage('Failed to load bathrooms: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshBathrooms() async {
    await fetchBathrooms();
  }

  Bathroom? getBathroomById(String id) {
    return bathrooms.firstWhereOrNull((bathroom) => bathroom.id == id);
  }

  Future<void> addBathroom(Bathroom bathroom) async {
    try {
      await _repository.createBathroom(bathroom);
      await fetchBathrooms();
    } catch (e) {
      errorMessage('Failed to add bathroom: $e');
    }
  }

  Future<void> updateBathroom(Bathroom bathroom) async {
    try {
      await _repository.updateBathroom(bathroom);
      await fetchBathrooms();
    } catch (e) {
      errorMessage('Failed to update bathroom: $e');
    }
  }


  Future<void> addReview(String bathroomId, Review review) async {
    try {
      await _repository.createReview(bathroomId, review);
      Get.snackbar('Success', 'Review added successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add review: $e');
    }
  }
}
