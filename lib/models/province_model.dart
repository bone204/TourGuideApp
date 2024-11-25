class Province {
  static const String defaultImageUrl = 'https://i2.ex-cdn.com/crystalbay.com/files/content/2023/11/26/vinwonders-1625.jpg';
  
  final String provinceId;
  final String provinceName;
  final String city;
  final List<String> district;
  final String imageUrl;
  final double rating;
  bool isFavorite;

  Province({
    required this.provinceId,
    required this.provinceName,
    required this.city,
    required this.district,
    required this.imageUrl,
    required this.rating,
    this.isFavorite = false,
  });

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      provinceId: map['provinceId'] ?? '',
      provinceName: map['provinceName'] ?? '',
      city: map['city'] ?? '',
      district: List<String>.from(map['district'] ?? []),
      imageUrl: map['imageUrl']?.toString().isNotEmpty == true 
          ? map['imageUrl'] 
          : defaultImageUrl,
      rating: (map['rating'] ?? 0).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}