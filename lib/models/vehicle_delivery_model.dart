class VehicleDeliveryModel {
  final String vehicleDeliTypeId;
  final String deliveryId;
  final String typeName;
  final double sizeLimit;
  final double weightLimit;
  final double priceLessThan10Km;
  final double priceMoreThan10Km;
  final int numberOfRooms;
  final String photo;
  final String note;

  VehicleDeliveryModel({
    required this.vehicleDeliTypeId,
    required this.deliveryId,
    required this.typeName,
    required this.sizeLimit,
    required this.weightLimit,
    required this.priceLessThan10Km,
    required this.priceMoreThan10Km,
    required this.numberOfRooms,
    required this.photo,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleDeliTypeId': vehicleDeliTypeId,
      'deliveryId': deliveryId,
      'typeName': typeName,
      'sizeLimit': sizeLimit,
      'weightLimit': weightLimit,
      'priceLessThan10Km': priceLessThan10Km,
      'priceMoreThan10Km': priceMoreThan10Km,
      'numberOfRooms': numberOfRooms,
      'photo': photo,
      'note': note,
    };
  }

  factory VehicleDeliveryModel.fromMap(Map<String, dynamic> map) {
    return VehicleDeliveryModel(
      vehicleDeliTypeId: map['vehicleDeliTypeId'] ?? '',
      deliveryId: map['deliveryId'] ?? '',
      typeName: map['typeName'] ?? '',
      sizeLimit: (map['sizeLimit'] ?? 0.0).toDouble(),
      weightLimit: (map['weightLimit'] ?? 0.0).toDouble(),
      priceLessThan10Km: (map['priceLessThan10Km'] ?? 0.0).toDouble(),
      priceMoreThan10Km: (map['priceMoreThan10Km'] ?? 0.0).toDouble(),
      numberOfRooms: map['numberOfRooms'] ?? 0,
      photo: map['photo'] ?? '',
      note: map['note'] ?? '',
    );
  }
}
