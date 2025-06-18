class VehicleInformationModel {
  final String vehicleTypeId;
  final String type;
  final String brand;
  final String model;
  final String color;
  final int seatingCapacity;
  final String fuelType;
  final String maxSpeed;
  final String photo;
  final String transmission;

  VehicleInformationModel({
    required this.vehicleTypeId,
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.seatingCapacity,
    required this.fuelType,
    required this.maxSpeed,
    required this.photo,
    required this.transmission,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleTypeId,
      'type': type,
      'brand': brand,
      'model': model,
      'color': color,
      'seatingCapacity': seatingCapacity,
      'fuelType': fuelType,
      'maxSpeed': maxSpeed,
      'photo': photo,
      'transmission': transmission,
    };
  }

  factory VehicleInformationModel.fromMap(Map<String, dynamic> map) {
    return VehicleInformationModel(
      vehicleTypeId: map['vehicleTypeId'] ?? '',
      type: map['type'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
      seatingCapacity: (map['seatingCapacity'] ?? 0).toInt(),
      fuelType: map['fuelType'] ?? '',
      maxSpeed: map['maxSpeed'] ?? '',
      photo: map['photo'] ?? '',
      transmission: map['transmission'] ?? '',
    );
  }
}
