class BusBillModel {
  final String billId;
  final String busTypeId;
  final String userId;
  final String pickUpLocation;
  final String endLocation;
  final String startDate;
  final String returnDate;
  final String returnPickUpLocation;
  final String returnEndLocation;
  final String createdDate;
  final int numberOfTickets;
  final double total;
  final String voucherId;
  final int travelPointsUsed;
  final String status;
  final List<String> seatNumberIds; // Gộp detail

  BusBillModel({
    required this.billId,
    required this.busTypeId,
    required this.userId,
    required this.pickUpLocation,
    required this.endLocation,
    required this.startDate,
    required this.returnDate,
    required this.returnPickUpLocation,
    required this.returnEndLocation,
    required this.createdDate,
    required this.numberOfTickets,
    required this.total,
    required this.voucherId,
    required this.travelPointsUsed,
    required this.status,
    required this.seatNumberIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'busTypeId': busTypeId,
      'userId': userId,
      'pickUpLocation': pickUpLocation,
      'endLocation': endLocation,
      'startDate': startDate,
      'returnDate': returnDate,
      'returnPickUpLocation': returnPickUpLocation,
      'returnEndLocation': returnEndLocation,
      'createdDate': createdDate,
      'numberOfTickets': numberOfTickets,
      'total': total,
      'voucherId': voucherId,
      'travelPointsUsed': travelPointsUsed,
      'status': status,
      'seatNumberIds': seatNumberIds,
    };
  }

  factory BusBillModel.fromMap(Map<String, dynamic> map) {
    return BusBillModel(
      billId: map['billId'] ?? '',
      busTypeId: map['busTypeId'] ?? '',
      userId: map['userId'] ?? '',
      pickUpLocation: map['pickUpLocation'] ?? '',
      endLocation: map['endLocation'] ?? '',
      startDate: map['startDate'] ?? '',
      returnDate: map['returnDate'] ?? '',
      returnPickUpLocation: map['returnPickUpLocation'] ?? '',
      returnEndLocation: map['returnEndLocation'] ?? '',
      createdDate: map['createdDate'] ?? '',
      numberOfTickets: map['numberOfTickets'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      voucherId: map['voucherId'] ?? '',
      travelPointsUsed: map['travelPointsUsed'] ?? 0,
      status: map['status'] ?? '',
      seatNumberIds: List<String>.from(map['seatNumberIds'] ?? []),
    );
  }
}
