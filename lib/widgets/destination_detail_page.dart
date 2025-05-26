// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_like_button.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/media_detail_view.dart';
import 'package:tourguideapp/widgets/video_thumbnail.dart';
import 'package:tourguideapp/widgets/cached_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DestinationDetailPage extends StatefulWidget {
  final HomeCardData cardData;
  final DestinationModel destinationData;
  final bool isFavourite;
  final ValueChanged<bool> onFavouriteToggle;
  final bool hideActions;
  final VoidCallback? onSaveTrip;

  const DestinationDetailPage({
    required this.cardData,
    required this.destinationData,
    required this.isFavourite,
    required this.onFavouriteToggle,
    this.hideActions = false,
    this.onSaveTrip,
    super.key,
  });

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  final DraggableScrollableController _dragController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final currentLocale = Localizations.localeOf(context).languageCode;

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
                  image: NetworkImage(widget.cardData.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // DraggableScrollableSheet
          Positioned.fill(
            bottom: MediaQuery.of(context).padding.bottom, // Thêm khoảng cách cho bottom bar
            child: DraggableScrollableSheet(
              controller: _dragController,
              initialChildSize: 0.6,
              minChildSize: 0.6,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35.r),
                      topRight: Radius.circular(35.r),
                    ),
                  ),
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        // Phần header cố định
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            _dragController.jumpTo(
                              _dragController.size - (details.delta.dy / MediaQuery.of(context).size.height),
                            );
                          },
                          child: Column(
                            children: [
                              // Drag indicator
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 12.h),
                                child: Center(
                                  child: Container(
                                    width: 40.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ),
                              ),

                              // Header content
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.cardData.placeName,
                                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: AppColors.orange, size: 24.sp),
                                        SizedBox(width: 4.w),
                                        Text(widget.cardData.description, style: TextStyle(color: AppColors.grey, fontSize: 14.sp)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Text(widget.cardData.rating.toString(), style: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                                        SizedBox(width: 10.w),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Row(
                                              children: [
                                                Icon(
                                                  index < widget.cardData.rating.round() ? Icons.star : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 14.sp,
                                                ),
                                                SizedBox(width: 2.w),
                                              ],
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // TabBar
                              TabBar(
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.red,
                                labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                                unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                                tabs: [
                                  Tab(text: AppLocalizations.of(context).translate('About')),
                                  Tab(text: AppLocalizations.of(context).translate('Review')),
                                  Tab(text: AppLocalizations.of(context).translate('Photo')),
                                  Tab(text: AppLocalizations.of(context).translate('Video')),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // TabBarView content (có thể scroll)
                        Expanded(
                          child: TabBarView(
                            children: [
                              // About tab
                              SingleChildScrollView(
                                controller: scrollController,
                                padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 100.h),
                                child: Text(
                                  currentLocale == 'en' 
                                      ? widget.destinationData.descriptionEng
                                      : widget.destinationData.descriptionViet,
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
                                ),
                              ),
                              // Review tab
                              SingleChildScrollView(
                                controller: scrollController,
                                padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 100.h),
                                child: Text(
                                  "Review: Duis aute irure dolor in reprehenderit in voluptate velit esse.",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
                                ),
                              ),
                              // Photo tab
                              SingleChildScrollView(
                                controller: scrollController,
                                padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 100.h),
                                child: MasonryGridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  itemCount: widget.destinationData.photo.length,
                                  itemBuilder: (context, index) {
                                    return Hero(
                                      tag: widget.destinationData.photo[index],
                                      child: CachedImage(
                                        imageUrl: widget.destinationData.photo[index],
                                        borderRadius: 16,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MediaDetailView(
                                                mediaUrl: widget.destinationData.photo[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Video tab
                              SingleChildScrollView(
                                controller: scrollController,
                                padding: EdgeInsets.fromLTRB(30.w, 0.h, 30.w, 100.h),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: widget.destinationData.video.length,
                                  itemBuilder: (context, index) => VideoThumbnail(
                                    videoUrl: widget.destinationData.video[index],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MediaDetailView(
                                            mediaUrl: widget.destinationData.video[index],
                                            isVideo: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 44.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (!widget.hideActions)
                    CustomLikeButton(
                      isLiked: widget.isFavourite,
                      onLikeChanged: widget.onFavouriteToggle,
                    ),
                ],
              ),
            ),
          ),
          if (widget.onSaveTrip != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(30.w, 0.h, 30.w, 12.h),
                    child: CustomElevatedButton(
                      text: widget.hideActions ? "Add to Route" : "Save a Trip",
                      onPressed: widget.onSaveTrip ?? () {},
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
