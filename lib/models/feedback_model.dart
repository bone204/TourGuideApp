class FeedbackModel {
  final String billId;
  final int rating;
  final String comment;
  final String createdAt;
  final String status;

  FeedbackModel({
    required this.billId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      billId: map['billId'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
