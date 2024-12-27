class RentalVehicleModel {
  final String vehicleRegisterId;
  final String userId;
  final String licensePlate;
  final String vehicleRegistration;
  final String vehicleType;
  final int maxSeats;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleRegistrationFrontPhoto;
  final String vehicleRegistrationBackPhoto;
  final double hour4Price;
  final double hour8Price;
  final double dayPrice;
  final List<String> requirements; 
  final String contractId;
  final String status;
  final String vehicleId;

  RentalVehicleModel({
    required this.vehicleRegisterId,
    required this.userId,
    required this.licensePlate,
    required this.vehicleRegistration,
    required this.vehicleType,
    required this.maxSeats,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleRegistrationFrontPhoto,
    required this.vehicleRegistrationBackPhoto,
    required this.hour4Price,
    required this.hour8Price,
    required this.dayPrice,
    required this.requirements,
    required this.contractId,
    required this.status,
    required this.vehicleId,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleRegisterId': vehicleRegisterId,
      'userId': userId,
      'licensePlate': licensePlate,
      'vehicleRegistration': vehicleRegistration,
      'vehicleType': vehicleType,
      'maxSeats': maxSeats,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleRegistrationFrontPhoto': vehicleRegistrationFrontPhoto,
      'vehicleRegistrationBackPhoto': vehicleRegistrationBackPhoto,
      'hour4Price': hour4Price,
      'hour8Price': hour8Price,
      'dayPrice': dayPrice,
      'requirements': requirements,
      'contractId': contractId,
      'status': status,
      'vehicleId': vehicleId,
    };
  }

  factory RentalVehicleModel.fromMap(Map<String, dynamic> map) {
    return RentalVehicleModel(
      vehicleRegisterId: map['vehicleRegisterId'] ?? '',
      userId: map['userId'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      vehicleRegistration: map['vehicleRegistration'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      maxSeats: (map['maxSeats'] ?? 0).toInt(),
      vehicleBrand: map['vehicleBrand'] ?? '',
      vehicleModel: map['vehicleModel'] ?? '',
      vehicleColor: map['vehicleColor'] ?? '',
      vehicleRegistrationFrontPhoto: map['vehicleRegistrationFrontPhoto'] ?? '',
      vehicleRegistrationBackPhoto: map['vehicleRegistrationBackPhoto'] ?? '',
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
      vehicleId: map['vehicleId'] ?? '',
    );
  }
}
