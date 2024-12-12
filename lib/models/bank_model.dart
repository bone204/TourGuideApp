class BankModel {
  final String bankId;
  final String bankName;
  final String bankSubName;

  BankModel({
    required this.bankId,
    required this.bankName,
    required this.bankSubName,
  });

  Map<String, dynamic> toMap() {
    return {
      'bankId': bankId,
      'bankName': bankName,
      'bankSubName': bankSubName,
    };
  }

  factory BankModel.fromMap(Map<String, dynamic> map) {
    return BankModel(
      bankId: map['bankId'] ?? '',
      bankName: map['bankName'] ?? '',
      bankSubName: map['bankSubName'] ?? '',
    );
  }
}
