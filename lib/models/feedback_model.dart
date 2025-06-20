class FeedbackModel {
  final String feedbackId;
  final String? travelRouteId;
  final String? destinationId;
  final String? licensePlate;
  final String? cooperationId;
  final String? userId;
  final String date;
  final int star;
  final String comment;
  final List<String>? photo;
  final List<String>? video;
  final String status;

  FeedbackModel({
    required this.feedbackId,
    this.travelRouteId,
    this.destinationId,
    this.licensePlate,
    this.cooperationId,
    this.userId,
    required this.date,
    required this.star,
    required this.comment,
    this.photo,
    this.video,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'travelRouteId': travelRouteId,
      'destinationId': destinationId,
      'licensePlate': licensePlate,
      'cooperationId': cooperationId,
      'userId': userId,
      'date': date,
      'star': star,
      'comment': comment,
      'photo': photo,
      'video': video,
      'status': status,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedbackId'] ?? '',
      travelRouteId: map['travelRouteId'] as String?,
      destinationId: map['destinationId'] as String?,
      licensePlate: map['licensePlate'] as String?,
      cooperationId: map['cooperationId'] as String?,
      userId: map['userId'] as String?,
      date: map['date'] ?? '',
      star: map['star'] ?? 0,
      comment: map['comment'] ?? '',
      photo: map['photo'] as List<String>?,
      video: map['video'] as List<String>?,
      status: map['status'] ?? '',
    );
  }
}
