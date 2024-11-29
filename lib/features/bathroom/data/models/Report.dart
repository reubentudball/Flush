import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String category;
  final String? description;
  final String userId;
  final Timestamp timestamp;

  Report({
    required this.category,
    this.description,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'userId': userId,
      'timestamp': timestamp,
    };
  }

  factory Report.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Report(
      category: data['category'] ?? 'Unknown',
      description: data['description'],
      userId: data['userId'] ?? 'Anonymous',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
