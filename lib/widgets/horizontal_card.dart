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
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
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
              height: 100,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.placeName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.price,
            style: const TextStyle(
              fontSize: 15,
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
                size: 20,
              ),
              Text(
                '${data.rating} (${data.ratingCount})',
                style: const TextStyle(
                  fontSize: 14,
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
