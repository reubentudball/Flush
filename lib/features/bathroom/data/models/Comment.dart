


class Comment{
  bool processed = false;
  String reviewText = "";
  double sentimentScore = 0.0;

  Comment({required this.processed, required this.reviewText, required this.sentimentScore});
  Comment.create({required this.processed, required this.reviewText, required this.sentimentScore});




  Map<String, dynamic> toMap() {
    return {
      "reviewText": reviewText,
      "processed": processed,
      "sentimentScore": sentimentScore,
    };
    }
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      reviewText: json['reviewText'] ?? '',  // Default value if null
      processed: json['processed'] ?? false, // Default value if null
      sentimentScore: (json['sentimentScore'] ?? 0).toDouble(), // Default value if null
    );
  }



}

/*

   */
