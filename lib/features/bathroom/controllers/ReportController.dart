import 'package:get/get.dart';
import '../data/models/Report.dart';
import '../data/service/ReportService.dart';

class ReportController extends GetxController {
  final ReportService _reportService = ReportService();
  final List<String> reportCategories = [
    "Broken Equipment",
    "Unclean",
    "No Supplies",
    "Odor",
    "Flooding",
    "Other"
  ];
  RxList<Report> reports = RxList<Report>();

  Future<void> submitReport(String bathroomId, Report report) async {
    try {
      await _reportService.submitReport(bathroomId, report);
      reports.add(report); // Update local state
      Get.snackbar("Success", "Report submitted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit report: $e");
    }
  }

  Future<void> fetchReports(String bathroomId) async {
    try {
      final fetchedReports = await _reportService.fetchReports(bathroomId);
      reports.assignAll(fetchedReports); // Update local state
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch reports: $e");
    }
  }
}
