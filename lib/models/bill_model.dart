class BillModel {
  final String billId;
  final String userId;
  final String startDate;
  final String endDate;
  final String rentalType;
  final double total;
  final String voucherId;
  final int travelPointsUsed;
  final String paymentMethod;
  final String status;
  final List<String> licensePlates;
  final String? citizenFrontPhoto;
  final String? citizenBackPhoto;
  final String? verifiedSefilePhoto;

  BillModel({
    required this.billId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.rentalType,
    required this.total,
    required this.voucherId,
    required this.travelPointsUsed,
    required this.paymentMethod,
    required this.status,
    required this.licensePlates,
    this.citizenFrontPhoto,
    this.citizenBackPhoto,
    this.verifiedSefilePhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
      'rentalType': rentalType,
      'total': total,
      'voucherId': voucherId,
      'travelPointsUsed': travelPointsUsed,
      'paymentMethod': paymentMethod,
      'status': status,
      'licensePlates': licensePlates,
      'citizenFrontPhoto': citizenFrontPhoto,
      'citizenBackPhoto': citizenBackPhoto,
      'verifiedSefilePhoto': verifiedSefilePhoto,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      billId: map['billId'] ?? '',
      userId: map['userId'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      rentalType: map['rentalType'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      voucherId: map['voucherId'] ?? '',
      travelPointsUsed: map['travelPointsUsed'] ?? 0,
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'Chờ thanh toán',
      licensePlates: List<String>.from(map['licensePlates'] ?? []),
      citizenFrontPhoto: map['citizenFrontPhoto'],
      citizenBackPhoto: map['citizenBackPhoto'],
      verifiedSefilePhoto: map['verifiedSefilePhoto'],
    );
  }
}
