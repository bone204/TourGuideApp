import 'package:flutter/material.dart';

class HorizontalCardData {
  final String imageUrl;
  final String placeName;
  final String description;
  final String price;
  final double rating;
  final int ratingCount;

  HorizontalCardData({
    required this.imageUrl,
    required this.placeName,
    required this.description,
    required this.price,
    required this.rating,
    required this.ratingCount,
  });
}

class HorizontalCard extends StatelessWidget {
  final HorizontalCardData data;

  const HorizontalCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình để tính toán
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4, // Card chiếm 40% chiều rộng màn hình
      margin: EdgeInsets.only(right: screenWidth * 0.03), // Khoảng cách giữa các card là 3% chiều rộng màn hình
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              data.imageUrl,
              height: screenWidth * 0.25, // Chiều cao ảnh là 25% của chiều rộng màn hình
              width: screenWidth * 0.4,  // Chiều rộng ảnh tương ứng với card
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.placeName,
            style: TextStyle(
              fontSize: screenWidth * 0.04, // Kích thước chữ dựa trên 4% chiều rộng màn hình
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: screenWidth * 0.035, // Kích thước text dựa trên 3.5% chiều rộng màn hình
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.price,
            style: TextStyle(
              fontSize: screenWidth * 0.04, // Kích thước giá dựa trên 4% chiều rộng màn hình
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.yellow[700],
                size: screenWidth * 0.05, // Kích thước icon là 5% chiều rộng màn hình
              ),
              Text(
                '${data.rating} (${data.ratingCount})',
                style: TextStyle(
                  fontSize: screenWidth * 0.035, // Kích thước chữ rating dựa trên 3.5% chiều rộng màn hình
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
