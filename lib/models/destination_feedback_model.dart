class DestinationFeedbackModel {
  final String destinationFeedbackId;
  final String destinationId;
  final String userId;
  final String date;
  final int star;
  final String comment;
  final List<String> photo; 
  final List<String> video; 

  DestinationFeedbackModel({
    required this.destinationFeedbackId,
    required this.destinationId,
    required this.userId,
    required this.date,
    required this.star,
    required this.comment,
    required this.photo,
    required this.video,
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationFeedbackId': destinationFeedbackId,
      'destinationId': destinationId,
      'userId': userId,
      'date': date,
      'star': star,
      'comment': comment,
      'photo': photo,
      'video': video,
    };
  }

  factory DestinationFeedbackModel.fromMap(Map<String, dynamic> map) {
    return DestinationFeedbackModel(
      destinationFeedbackId: map['destinationFeedbackId'] ?? '',
      destinationId: map['destinationId'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      star: map['star'] ?? 0,
      comment: map['comment'] ?? '',
      photo: List<String>.from(map['photo'] ?? []),
      video: List<String>.from(map['video'] ?? []),
    );
  }
}
