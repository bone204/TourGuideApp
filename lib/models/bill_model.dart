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
  final String accountPayment;
  final String vehicleRegisterId;

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
    required this.accountPayment,
    required this.vehicleRegisterId,
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
      'accountPayment': accountPayment,
      'vehicleRegisterId': vehicleRegisterId,
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
      accountPayment: map['accountPayment'] ?? '',
      vehicleRegisterId: map['vehicleRegisterId'] ?? '',
    );
  }
}
