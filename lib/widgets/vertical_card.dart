import 'package:flutter/material.dart';

class VerticalCardData {
  final String imageUrl;
  final String placeName;
  final String description;
  final String price;

  VerticalCardData({
    required this.imageUrl,
    required this.placeName,
    required this.description,
    required this.price,
  });
}

class VerticalCard extends StatelessWidget {
  final VerticalCardData data;

  const VerticalCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình hiện tại
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Tính toán chiều cao và chiều rộng phù hợp dựa trên kích thước màn hình
    double imageHeight = screenHeight * 0.12; // 12% chiều cao màn hình
    double imageWidth = screenWidth * 0.25;   // 25% chiều rộng màn hình
    double fontSizeTitle = screenWidth * 0.04; // Cỡ chữ dựa trên chiều rộng

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Thêm khoảng cách giữa các thẻ
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              data.imageUrl,
              height: imageHeight,
              width: imageWidth,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.placeName,
                  style: TextStyle(
                    fontSize: fontSizeTitle, // Responsive cỡ chữ tiêu đề
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // Responsive cỡ chữ mô tả
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.price,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Responsive cỡ chữ giá
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
