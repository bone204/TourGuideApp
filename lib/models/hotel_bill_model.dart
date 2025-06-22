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

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'userId': userId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'createdDate': createdDate,
      'numberOfRooms': numberOfRooms,
      'total': total,
      'voucherId': voucherId,
      'travelPointsUsed': travelPointsUsed,
      'status': status,
      'roomIds': roomIds,
    };
  }

  HotelBillModel copyWith({
    String? billId,
    String? userId,
    String? checkInDate,
    String? checkOutDate,
    String? createdDate,
    int? numberOfRooms,
    double? total,
    String? voucherId,
    int? travelPointsUsed,
    String? status,
    List<String>? roomIds,
  }) {
    return HotelBillModel(
      billId: billId ?? this.billId,
      userId: userId ?? this.userId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      createdDate: createdDate ?? this.createdDate,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      total: total ?? this.total,
      voucherId: voucherId ?? this.voucherId,
      travelPointsUsed: travelPointsUsed ?? this.travelPointsUsed,
      status: status ?? this.status,
      roomIds: roomIds ?? this.roomIds,
    );
  }
}
