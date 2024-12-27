class BillDetailModel {
  final String billId;
  final String licensePlate;
  final int number;
  final double total;
  final String citizenFrontPhoto;
  final String citizenBackPhoto;
  final String citizenHandoverPhoto;

  BillDetailModel({
    required this.billId,
    required this.licensePlate,
    required this.number,
    required this.total,
    required this.citizenFrontPhoto,
    required this.citizenBackPhoto,
    required this.citizenHandoverPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'licensePlate': licensePlate,
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
      licensePlate: map['licensePlate'] ?? '',
      number: map['number'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      citizenFrontPhoto: map['citizenFrontPhoto'] ?? '',
      citizenBackPhoto: map['citizenBackPhoto'] ?? '',
      citizenHandoverPhoto: map['citizenHandoverPhoto'] ?? '',
    );
  }
}
