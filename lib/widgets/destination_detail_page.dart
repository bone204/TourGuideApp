import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_like_button.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';

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
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      body: Stack(
        children: [
          // Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400.h, // Fixed height for the image
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: DefaultTabController(
                  length: 4,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
                          child: Text(
                            data.placeName,
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey[600]),
                              SizedBox(width: 6.w),
                              Text(data.description, style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Rating
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Row(
                            children: [
                              Text(data.rating.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                              SizedBox(width: 10.w),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < data.rating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 12.sp,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28.h),

                        // TabBar
                        TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.red,
                          labelStyle: TextStyle(
                            fontSize: 14.sp, 
                            fontWeight: FontWeight.bold, 
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 14.sp, 
                            fontWeight: FontWeight.bold, 
                          ),
                          tabs: const [
                            Tab(text: 'About'),
                            Tab(text: 'Review'),
                            Tab(text: 'Photo'),
                            Tab(text: 'Video'),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: SizedBox(
                            height: 200, 
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
                        ),
                        SizedBox(height: 30.h),
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
            bottom: 20.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: CustomElevatedButton(
                text: "Save a Trip",
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
