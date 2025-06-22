import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/widgets/media_detail_view.dart';
import 'package:tourguideapp/widgets/video_thumbnail.dart';
import 'package:tourguideapp/widgets/cached_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DestinationDetailDraggableSheet extends StatefulWidget {
  final HomeCardData cardData;
  final DestinationModel destinationData;
  final bool isFavourite;
  final ValueChanged<bool> onFavouriteToggle;
  final bool hideActions;
  final VoidCallback? onSaveTrip;

  const DestinationDetailDraggableSheet({
    required this.cardData,
    required this.destinationData,
    required this.isFavourite,
    required this.onFavouriteToggle,
    this.hideActions = false,
    this.onSaveTrip,
    super.key,
  });

  @override
  State<DestinationDetailDraggableSheet> createState() => _DestinationDetailDraggableSheetState();
}

class _DestinationDetailDraggableSheetState extends State<DestinationDetailDraggableSheet> {
  final DraggableScrollableController _dragController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final cardData = widget.cardData;
    final destination = widget.destinationData;
    return Stack(
      children: [
        // DraggableScrollableSheet
        Positioned.fill(
          bottom: MediaQuery.of(context).padding.bottom,
          child: DraggableScrollableSheet(
            controller: _dragController,
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.95,
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
                      // Drag indicator
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (details) {
                          _dragController.jumpTo(
                            _dragController.size -
                                (details.delta.dy / MediaQuery.of(context).size.height),
                          );
                        },
                        child: Container(
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
                      ),
                      // Header content
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cardData.placeName,
                              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: AppColors.primaryColor, size: 24.w),
                                SizedBox(width: 4.w),
                                Text(cardData.description, style: TextStyle(color: AppColors.grey, fontSize: 14.sp)),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Text(cardData.rating.toString(),
                                    style: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                                SizedBox(width: 10.w),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Row(
                                      children: [
                                        Icon(
                                          index < cardData.rating.round() ? Icons.star : Icons.star_border,
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
                      // TabBarView content
                      Expanded(
                        child: TabBarView(
                          children: [
                            // About tab
                            SingleChildScrollView(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 100.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Thông tin chi tiết', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                                  SizedBox(height: 15.h),
                                  if (destination.specificAddress.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.location_on, color: AppColors.primaryColor, size: 20.sp),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text('Địa chỉ: ${destination.specificAddress}', style: TextStyle(color: Colors.grey[700], fontSize: 14.sp)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.h),
                                  ],
                                  Text(
                                    destination.descriptionViet.isNotEmpty
                                        ? destination.descriptionViet
                                        : 'Chưa có mô tả chi tiết cho địa điểm này.',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14.sp, height: 1.5),
                                  ),
                                  SizedBox(height: 20.h),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 18.sp),
                                      SizedBox(width: 8.w),
                                      Text('${destination.rating.toStringAsFixed(1)}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                                      SizedBox(width: 8.w),
                                      Text('(${destination.userRatingsTotal} đánh giá)', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                                    ],
                                  ),
                                  SizedBox(height: 15.h),
                                  Row(
                                    children: [
                                      Icon(Icons.favorite, color: Colors.red, size: 18.sp),
                                      SizedBox(width: 8.w),
                                      Text('${destination.favouriteTimes} lượt yêu thích', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Review tab
                            SingleChildScrollView(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 100.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Đánh giá từ khách hàng', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                                  SizedBox(height: 15.h),
                                  if (destination.userRatingsTotal > 0) ...[
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Text(destination.rating.toStringAsFixed(1), style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700, color: AppColors.primaryColor)),
                                              SizedBox(height: 5.h),
                                              Row(
                                                children: List.generate(5, (index) {
                                                  return Icon(
                                                    index < destination.rating.round() ? Icons.star : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 16.sp,
                                                  );
                                                }),
                                              ),
                                              SizedBox(height: 5.h),
                                              Text('${destination.userRatingsTotal} đánh giá', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                                            ],
                                          ),
                                          SizedBox(width: 20.w),
                                          Expanded(
                                            child: Text('Địa điểm này nhận được đánh giá tích cực từ cộng đồng du lịch.', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                  ],
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.rate_review, size: 48.sp, color: Colors.grey[400]),
                                        SizedBox(height: 16.h),
                                        Text('Chưa có đánh giá chi tiết', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                        SizedBox(height: 8.h),
                                        Text('Đánh giá chi tiết sẽ được hiển thị ở đây\nkhi tích hợp với Places API', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Photo tab
                            SingleChildScrollView(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(10.w, 0.h, 10.w, 100.h),
                              child: MasonryGridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                itemCount: destination.photo.length,
                                itemBuilder: (context, index) {
                                  return Hero(
                                    tag: destination.photo[index],
                                    child: CachedImage(
                                      imageUrl: destination.photo[index],
                                      borderRadius: 16,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MediaDetailView(
                                              mediaUrl: destination.photo[index],
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
                              padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 100.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Video về địa điểm', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                                  SizedBox(height: 20.h),
                                  if (destination.video.isNotEmpty) ...[
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: destination.video.length,
                                      itemBuilder: (context, index) => VideoThumbnail(
                                        videoUrl: destination.video[index],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MediaDetailView(
                                                mediaUrl: destination.video[index],
                                                isVideo: true,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ] else ...[
                                    Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.videocam_off, size: 48.sp, color: Colors.grey[400]),
                                          SizedBox(height: 16.h),
                                          Text('Chưa có video', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8.h),
                                          Text('Video về địa điểm này sẽ được hiển thị ở đây\nkhi có dữ liệu từ Places API', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
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
      ],
    );
  }
} 