import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReport(String bathroomId, Report report) async {
    try {
      final reportRef = _firestore
          .collection('Bathroom')
          .doc(bathroomId)
          .collection('Reports');

      await reportRef.add(report.toJson());
    } catch (e) {
      throw Exception("Error submitting report: $e");
    }
  }

  Future<List<Report>> fetchReports(String bathroomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Bathroom')
          .doc(bathroomId)
          .collection('Reports')
          .get();

      return querySnapshot.docs
          .map((doc) => Report.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception("Error fetching reports: $e");
    }
  }
}
