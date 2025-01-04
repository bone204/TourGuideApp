class BillDetailModel {
  final String billId;
  final String vehicleRegisterId;
  final int number;
  final double total;
  final String citizenFrontPhoto;
  final String citizenBackPhoto;
  final String citizenHandoverPhoto;

  BillDetailModel({
    required this.billId,
    required this.vehicleRegisterId,
    required this.number,
    required this.total,
    required this.citizenFrontPhoto,
    required this.citizenBackPhoto,
    required this.citizenHandoverPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'vehicleRegisterId': vehicleRegisterId,
      'number': number,
      'total': total,
      'citizenFrontPhoto': citizenFrontPhoto,
      'citizenBackPhoto': citizenBackPhoto,
      'citizenHandoverPhoto': citizenHandoverPhoto,
    };
  }

  factory BillDetailModel.fromMap(Map<String, dynamic> map) {
    return BillDetailModel(
      billId: map['billId'] ?? '',
      vehicleRegisterId: map['vehicleRegisterId'] ?? '',
      number: map['number'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      citizenFrontPhoto: map['citizenFrontPhoto'] ?? '',
      citizenBackPhoto: map['citizenBackPhoto'] ?? '',
      citizenHandoverPhoto: map['citizenHandoverPhoto'] ?? '',
    );
  }
}
