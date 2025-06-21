class HotelBillModel {
  final String billId;
  final String userId;
  final String checkInDate;
  final String checkOutDate;
  final String createdDate;
  final int numberOfRooms;
  final double total;
  final String voucherId;
  final int travelPointsUsed;
  final String status;
  final List<String> roomIds; // Gộp detail

  HotelBillModel({
    required this.billId,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.createdDate,
    required this.numberOfRooms,
    required this.total,
    required this.voucherId,
    required this.travelPointsUsed,
    required this.status,
    required this.roomIds,
  });

  factory HotelBillModel.fromMap(Map<String, dynamic> map) {
    return HotelBillModel(
      billId: map['billId'] ?? '',
      userId: map['userId'] ?? '',
      checkInDate: map['checkInDate'] ?? '',
      checkOutDate: map['checkOutDate'] ?? '',
      createdDate: map['createdDate'] ?? '',
      numberOfRooms: map['numberOfRooms'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      voucherId: map['voucherId'] ?? '',
      travelPointsUsed: map['travelPointsUsed'] ?? 0,
      status: map['status'] ?? '',
      roomIds: List<String>.from(map['roomIds'] ?? []),
    );
  }
}
