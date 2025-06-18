class RentalVehicleModel {
  final String licensePlate;
  final String userId;
  final String vehicleRegistration;
  final String vehicleTypeId;
  final String vehicleRegistrationFront;
  final String vehicleRegistrationBack;
  final double hour4Price;
  final double hour8Price;
  final double dayPrice;
  final List<String> requirements; 
  final String contractId;
  final String status;

  RentalVehicleModel({
    required this.userId,
    required this.licensePlate,
    required this.vehicleRegistration,
    required this.vehicleTypeId,
    required this.vehicleRegistrationFront,
    required this.vehicleRegistrationBack,
    required this.hour4Price,
    required this.hour8Price,
    required this.dayPrice,
    required this.requirements,
    required this.contractId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'licensePlate': licensePlate,
      'vehicleRegistration': vehicleRegistration,
      'vehicleTypeId': vehicleTypeId,
      'vehicleRegistrationFrontPhoto': vehicleRegistrationFront,
      'vehicleRegistrationBackPhoto': vehicleRegistrationBack,
      'hour4Price': hour4Price,
      'hour8Price': hour8Price,
      'dayPrice': dayPrice,
      'requirements': requirements,
      'contractId': contractId,
      'status': status,
    };
  }

  factory RentalVehicleModel.fromMap(Map<String, dynamic> map) {
    return RentalVehicleModel(
      userId: map['userId'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      vehicleRegistration: map['vehicleRegistration'] ?? '',
      vehicleTypeId: map['vehicleTypeId'] ?? '',
      vehicleRegistrationFront: map['vehicleRegistrationFront'] ?? '',
      vehicleRegistrationBack: map['vehicleRegistrationBack'] ?? '',
      hour4Price: (map['hour4Price'] is int)
          ? (map['hour4Price'] as int).toDouble()
          : (map['hour4Price'] ?? 0.0).toDouble(),
      hour8Price: (map['hour8Price'] is int)
          ? (map['hour8Price'] as int).toDouble()
          : (map['hour8Price'] ?? 0.0).toDouble(),
      dayPrice: (map['dayPrice'] is int)
          ? (map['dayPrice'] as int).toDouble()
          : (map['dayPrice'] ?? 0.0).toDouble(),
      requirements: List<String>.from(map['requirements'] ?? []),
      contractId: map['contractId'] ?? '',
      status: map['status'] ?? 'Pending Approval',
    );
  }
}
