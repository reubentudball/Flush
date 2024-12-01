class Comment {
  bool processed;
  String reviewText;
  double sentimentScore;
  String userID;

  Comment({
    required this.processed,
    required this.reviewText,
    required this.sentimentScore,
    required this.userID,
  });

  Map<String, dynamic> toMap() {
    return {
      "reviewText": reviewText,
      "processed": processed,
      "sentimentScore": sentimentScore,
      "userID": userID,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      reviewText: json['reviewText'] ?? '',
      processed: json['processed'] ?? false,
      sentimentScore: (json['sentimentScore'] ?? 0).toDouble(),
      userID: json['userID'] ?? 'UnknownUserID',
    );
  }
}
