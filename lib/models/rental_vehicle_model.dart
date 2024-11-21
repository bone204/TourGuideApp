class RentalVehicleModel {
  final String licensePlate;
  final String vehicleId;
  final int manufactureYear;
  final double hourPrice;
  final double dayPrice;
  final String vehicleRegistrationFront;
  final String vehicleRegistrationBack;
  final String contractId;
  final List<String> requirements; // List of rental requirements
  final String status;

  RentalVehicleModel({
    required this.licensePlate,
    required this.vehicleId,
    required this.manufactureYear,
    required this.hourPrice,
    required this.dayPrice,
    required this.vehicleRegistrationFront,
    required this.vehicleRegistrationBack,
    required this.contractId,
    required this.requirements,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'licensePlate': licensePlate,
      'vehicleId': vehicleId,
      'manufactureYear': manufactureYear,
      'hourPrice': hourPrice,
      'dayPrice': dayPrice,
      'vehicleRegistrationFront': vehicleRegistrationFront,
      'vehicleRegistrationBack': vehicleRegistrationBack,
      'contractId': contractId,
      'requirements': requirements,
      'status': status,
    };
  }

  factory RentalVehicleModel.fromMap(Map<String, dynamic> map) {
    return RentalVehicleModel(
      licensePlate: map['licensePlate'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      manufactureYear: map['manufactureYear'] ?? 0,
      hourPrice: (map['hourPrice'] ?? 0.0).toDouble(),
      dayPrice: (map['dayPrice'] ?? 0.0).toDouble(),
      vehicleRegistrationFront: map['vehicleRegistrationFront'] ?? '',
      vehicleRegistrationBack: map['vehicleRegistrationBack'] ?? '',
      contractId: map['contractId'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      status: map['status'] ?? '',
    );
  }
}
