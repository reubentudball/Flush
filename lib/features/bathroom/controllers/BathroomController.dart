import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/models/Comment.dart';
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
    _streamBathrooms();
  }

  void _streamBathrooms() {
    _repository.streamBathrooms().listen(
          (data) {
        bathrooms.value = data;
      },
      onError: (e) {
        errorMessage('Failed to load bathrooms: $e');
      },
    );
  }

  Future<void> addBathroom(Bathroom bathroom) async {
    try {
      await _repository.createBathroom(bathroom);
      Get.snackbar('Success', 'Bathroom added successfully.');
    } catch (e) {
      errorMessage('Failed to add bathroom: $e');
      Get.snackbar('Error', 'Failed to add bathroom: $e');
    }
  }

  Future<void> updateBathroom(Bathroom bathroom) async {
    try {
      await _repository.updateBathroom(bathroom);

      final refreshedBathroom = await _repository.getBathroomById(bathroom.id!);

      if(refreshedBathroom != null){
        final index = bathrooms.indexWhere((b) => b.id == bathroom.id);
        if (index != -1){
          bathrooms[index] = refreshedBathroom;
        }
      }

      await refreshLocalBathrooms();

      Get.snackbar('Success', 'Bathroom updated successfully.');
    } catch (e) {
      errorMessage('Failed to update bathroom: $e');
      Get.snackbar('Error', 'Failed to update bathroom: $e');
    }
  }

  Future<void> deleteBathroom(String id) async {
    try {
      await _repository.deleteBathroom(id);

      bathrooms.removeWhere((b) => b.id == id);

      await refreshLocalBathrooms();

      Get.snackbar('Success', 'Bathroom deleted successfully.');
    } catch (e) {
      errorMessage('Failed to delete bathroom: $e');
      Get.snackbar('Error', 'Failed to delete bathroom: $e');
    }
  }

  Future<void> addReview(String bathroomId, Review review) async {
    try {
      await _repository.createReview(bathroomId, review);
      Get.snackbar('Success', 'Review added successfully.');
    } catch (e) {
      errorMessage('Failed to add review: $e');
      Get.snackbar('Error', 'Failed to add review: $e');
    }
  }

  Bathroom? getBathroomById(String id) {
    return bathrooms.firstWhereOrNull((bathroom) => bathroom.id == id);
  }

  Future<void> refreshLocalBathrooms() async {
    try {
      final List<String> bathroomIds = bathrooms.map((b) => b.id!).toList();

      final updatedBathrooms = await _repository.refreshBathrooms(bathroomIds);

      bathrooms.value = updatedBathrooms;

    } catch (e) {
      errorMessage('Failed to refresh bathrooms: $e');
    }
  }

  Future<void> addComment(String bathroomId, Comment comment) async {
    try {
      await _repository.addComment(bathroomId, comment);

      // Update local comments
      final bathroom = getBathroomById(bathroomId);
      if (bathroom != null) {
        bathroom.comments?.add(comment);
        bathrooms.refresh();
      }

      Get.snackbar('Success', 'Comment added successfully.');
    } catch (e) {
      errorMessage('Failed to add comment: $e');
      Get.snackbar('Error', 'Failed to add comment: $e');
    }
  }

  Future<List<Comment>> fetchComments(String bathroomId) async {
    try {
      return await _repository.getBathroomComments(bathroomId);
    } catch (e) {
      errorMessage('Failed to fetch comments: $e');
      return [];
    }
  }

}

