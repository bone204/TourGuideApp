class ContractModel {
  final String contractId;
  final String userId;
  final String businessType;
  final String businessName;
  final String businessProvince;
  final String businessAddress;
  final String taxCode;
  final String businessRegisterPhoto;
  final String citizenFrontPhoto;
  final String citizenBackPhoto;
  final String contractTerm;
  final String contractStatus;
  final String businessLocation;
  final String businessCity;
  final String businessDistrict;
  ContractModel({
    required this.contractId,
    required this.userId,
    required this.businessType,
    required this.businessName,
    required this.businessProvince,
    required this.businessAddress,
    required this.taxCode,
    required this.businessRegisterPhoto,
    required this.citizenFrontPhoto,
    required this.citizenBackPhoto,
    required this.contractTerm,
    required this.contractStatus,
    required this.businessLocation,
    required this.businessCity,
    required this.businessDistrict,
  });
  Map<String, dynamic> toMap() {
    return {
      'contractId': contractId,
      'userId': userId,
      'businessType': businessType,
      'businessName': businessName,
      'businessProvince': businessProvince,
      'businessAddress': businessAddress,
      'taxCode': taxCode,
      'businessRegisterPhoto': businessRegisterPhoto,
      'citizenFrontPhoto': citizenFrontPhoto,
      'citizenBackPhoto': citizenBackPhoto,
      'contractTerm': contractTerm,
      'contractStatus': contractStatus,
      'businessLocation': businessLocation,
      'businessCity': businessCity,
      'businessDistrict': businessDistrict,
    };
  }
  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      contractId: map['contractId'] ?? '',
      userId: map['userId'] ?? '',
      businessType: map['businessType'] ?? '',
      businessName: map['businessName'] ?? '',
      businessProvince: map['businessProvince'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      taxCode: map['taxCode'] ?? '',
      businessRegisterPhoto: map['businessRegisterPhoto'] ?? '',
      citizenFrontPhoto: map['citizenFrontPhoto'] ?? '',
      citizenBackPhoto: map['citizenBackPhoto'] ?? '',
      contractTerm: map['contractTerm'] ?? '',
      contractStatus: map['contractStatus'] ?? '',
      businessLocation: map['businessLocation'] ?? '',
      businessCity: map['businessCity'] ?? '',
      businessDistrict: map['businessDistrict'] ?? '',
    );
  }
}