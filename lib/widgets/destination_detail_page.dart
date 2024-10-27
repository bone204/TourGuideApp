import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/custom_like_button.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class DestinationDetailPage extends StatelessWidget {
  final HorizontalCardData data;
  final bool isFavourite;
  final ValueChanged<bool> onFavouriteToggle; // Thêm callback

  const DestinationDetailPage({
    required this.data,
    required this.isFavourite,
    required this.onFavouriteToggle, // Thêm vào constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 500, // Fixed height for the image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(data.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // DraggableScrollableSheet for content
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: DefaultTabController(
                  length: 4,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.placeName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(data.description, style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        Row(
                          children: [
                            Text(data.rating.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            const SizedBox(width: 4),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < data.rating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // TabBar
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.red,
                          tabs: [
                            Tab(text: 'About'),
                            Tab(text: 'Review'),
                            Tab(text: 'Photo'),
                            Tab(text: 'Video'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // TabBarView
                        SizedBox(
                          height: 200, // Fixed height for TabBarView
                          child: TabBarView(
                            children: [
                              // About
                              Text(
                                "About: Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                              // Review
                              Text(
                                "Review: Duis aute irure dolor in reprehenderit in voluptate velit esse.",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                              // Photo
                              Text(
                                "Photo: Excepteur sint occaecat cupidatat non proident.",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                              // Video
                              Text(
                                "Video: Sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Nút quay lại
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
            ),
          ),
          // Nút thích
          Positioned(
            top: 40,
            right: 20,
            child: CustomLikeButton(
              isLiked: isFavourite,
              onLikeChanged: onFavouriteToggle, // Gọi callback khi nhấn nút thích
            ),
          ),
          // Nút Save a Trip cố định ở đáy
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFFF36D72),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Save a Trip",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
