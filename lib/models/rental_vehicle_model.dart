class RentalVehicleModel {
  final String vehicleId;
  final String userId;
  final String licensePlate;
  final String vehicleRegistration;
  final String vehicleType;
  final int maxSeats;
  final String vehicleBrand;
  final String vehicleModel;
  final String description;
  final String vehicleRegistrationFrontPhoto;
  final String vehicleRegistrationBackPhoto;
  final double hourPrice;
  final double dayPrice;
  final List<String> requirements; 
  final String contractId;
  final String status;

  RentalVehicleModel({
    required this.vehicleId,
    required this.userId,
    required this.licensePlate,
    required this.vehicleRegistration,
    required this.vehicleType,
    required this.maxSeats,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.description,
    required this.vehicleRegistrationFrontPhoto,
    required this.vehicleRegistrationBackPhoto,
    required this.hourPrice,
    required this.dayPrice,
    required this.requirements,
    required this.contractId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'licensePlate': licensePlate,
      'vehicleRegistration': vehicleRegistration,
      'vehicleType': vehicleType,
      'maxSeats': maxSeats,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'description': description,
      'vehicleRegistrationFrontPhoto': vehicleRegistrationFrontPhoto,
      'vehicleRegistrationBackPhoto': vehicleRegistrationBackPhoto,
      'hourPrice': hourPrice,
      'dayPrice': dayPrice,
      'requirements': requirements,
      'contractId': contractId,
      'status': status,
    };
  }

  factory RentalVehicleModel.fromMap(Map<String, dynamic> map) {
    return RentalVehicleModel(
      vehicleId: map['vehicleId'] ?? '',
      userId: map['userId'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      vehicleRegistration: map['vehicleRegistration'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      maxSeats: (map['maxSeats'] ?? 0).toInt(),
      vehicleBrand: map['vehicleBrand'] ?? '',
      vehicleModel: map['vehicleModel'] ?? '',
      description: map['description'] ?? '',
      vehicleRegistrationFrontPhoto: map['vehicleRegistrationFrontPhoto'] ?? '',
      vehicleRegistrationBackPhoto: map['vehicleRegistrationBackPhoto'] ?? '',
      hourPrice: (map['hourPrice'] ?? 0.0).toDouble(),
      dayPrice: (map['dayPrice'] ?? 0.0).toDouble(),
      requirements: List<String>.from(map['requirements'] ?? []),
      contractId: map['contractId'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
