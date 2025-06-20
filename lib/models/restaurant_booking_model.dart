class RestaurantBookingModel {
  final String bookingId;
  final String userId;
  final String checkInDate;
  final String createdDate;
  final String tableId;
  final String status;

  RestaurantBookingModel({
    required this.bookingId,
    required this.userId,
    required this.checkInDate,
    required this.createdDate,
    required this.tableId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'checkInDate': checkInDate,
      'createdDate': createdDate,
      'tableId': tableId,
      'status': status,
    };
  }

  factory RestaurantBookingModel.fromMap(Map<String, dynamic> map) {
    return RestaurantBookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      checkInDate: map['checkInDate'] ?? '',
      createdDate: map['createdDate'] ?? '',
      tableId: map['tableId'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
