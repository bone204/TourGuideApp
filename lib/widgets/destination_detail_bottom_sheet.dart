import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';

class DestinationDetailBottomSheet extends StatelessWidget {
  final DestinationModel destination;
  const DestinationDetailBottomSheet({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                destination.destinationName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      destination.specificAddress,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                destination.descriptionViet.isNotEmpty
                    ? destination.descriptionViet
                    : 'Chưa có mô tả chi tiết cho địa điểm này.',
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    destination.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text('(${destination.userRatingsTotal} đánh giá)'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Text('${destination.favouriteTimes} lượt yêu thích'),
                ],
              ),
              // Thêm các thông tin khác nếu muốn
            ],
          ),
        ),
      ),
    );
  }
}
