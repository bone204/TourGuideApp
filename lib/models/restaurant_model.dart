class RestaurantModel {
  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final double rating;
  final double pricePerPerson;
  final String address;

  RestaurantModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.imageUrl,
    required this.rating,
    required this.pricePerPerson,
    required this.address,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      pricePerPerson: (map['pricePerPerson'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
    );
  }
} 