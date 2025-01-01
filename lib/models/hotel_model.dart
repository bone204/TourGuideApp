class HotelModel {
  final String hotelId;
  final String hotelName;
  final String imageUrl;
  final double rating;
  final double pricePerDay;
  final String address;

  HotelModel({
    required this.hotelId,
    required this.hotelName,
    required this.imageUrl,
    required this.rating,
    required this.pricePerDay,
    required this.address,
  });

  factory HotelModel.fromMap(Map<String, dynamic> map) {
    return HotelModel(
      hotelId: map['hotelId'] ?? '',
      hotelName: map['hotelName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      pricePerDay: (map['pricePerDay'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
    );
  }
} 