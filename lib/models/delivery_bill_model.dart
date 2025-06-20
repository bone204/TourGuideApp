class DeliveryBillModel {
  final String billId;
  final String userId;
  final String vehicleDeliTypeId;
  final String deliveryDate;
  final String deliveryAddress;
  final String createdDate;
  final String description;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final double total;
  final String voucherId;
  final int travelPointsUsed;
  final String status;

  DeliveryBillModel({
    required this.billId,
    required this.userId,
    required this.vehicleDeliTypeId,
    required this.deliveryDate,
    required this.deliveryAddress,
    required this.createdDate,
    required this.description,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.total,
    required this.voucherId,
    required this.travelPointsUsed,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'userId': userId,
      'vehicleDeliTypeId': vehicleDeliTypeId,
      'deliveryDate': deliveryDate,
      'deliveryAddress': deliveryAddress,
      'createdDate': createdDate,
      'description': description,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverAddress': receiverAddress,
      'total': total,
      'voucherId': voucherId,
      'travelPointsUsed': travelPointsUsed,
      'status': status,
    };
  }

  factory DeliveryBillModel.fromMap(Map<String, dynamic> map) {
    return DeliveryBillModel(
      billId: map['billId'] ?? '',
      userId: map['userId'] ?? '',
      vehicleDeliTypeId: map['vehicleDeliTypeId'] ?? '',
      deliveryDate: map['deliveryDate'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      createdDate: map['createdDate'] ?? '',
      description: map['description'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverPhone: map['receiverPhone'] ?? '',
      receiverAddress: map['receiverAddress'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      voucherId: map['voucherId'] ?? '',
      travelPointsUsed: map['travelPointsUsed'] ?? 0,
      status: map['status'] ?? '',
    );
  }
}
