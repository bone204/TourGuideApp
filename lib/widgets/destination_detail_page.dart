// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
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
  final DraggableScrollableController _dragController =
      DraggableScrollableController();

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
            bottom: MediaQuery.of(context)
                .padding
                .bottom, // Thêm khoảng cách cho bottom bar
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
                              _dragController.size -
                                  (details.delta.dy /
                                      MediaQuery.of(context).size.height),
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
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.cardData.placeName,
                                      style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/img/ic_location.png',
                                          height: 24.w,
                                          width: 24.w,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(widget.cardData.description,
                                            style: TextStyle(
                                                color: AppColors.grey,
                                                fontSize: 14.sp)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Text(widget.cardData.rating.toString(),
                                            style: TextStyle(
                                                color: AppColors.grey,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(width: 10.w),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Row(
                                              children: [
                                                Icon(
                                                  index <
                                                          widget.cardData.rating
                                                              .round()
                                                      ? Icons.star
                                                      : Icons.star_border,
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
                                labelStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700),
                                tabs: [
                                  Tab(
                                      text: AppLocalizations.of(context)
                                          .translate('About')),
                                  Tab(
                                      text: AppLocalizations.of(context)
                                          .translate('Review')),
                                  Tab(
                                      text: AppLocalizations.of(context)
                                          .translate('Photo')),
                                  Tab(
                                      text: AppLocalizations.of(context)
                                          .translate('Video')),
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
                                padding: EdgeInsets.fromLTRB(
                                    30.w, 20.h, 30.w, 100.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thông tin cơ bản
                                    Text(
                                      'Thông tin chi tiết',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    // Địa chỉ cụ thể
                                    if (widget.destinationData.specificAddress
                                        .isNotEmpty) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: AppColors.primaryColor,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              'Địa chỉ: ${widget.destinationData.specificAddress}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                    ],
                                    // Mô tả chi tiết
                                    Text(
                                      widget.destinationData.descriptionViet
                                              .isNotEmpty
                                          ? widget
                                              .destinationData.descriptionViet
                                          : 'Chưa có mô tả chi tiết cho địa điểm này.',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14.sp,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    // Thông tin đánh giá
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '${widget.destinationData.rating.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '(${widget.destinationData.userRatingsTotal} đánh giá)',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.h),
                                    // Số lượt yêu thích
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '${widget.destinationData.favouriteTimes} lượt yêu thích',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Review tab
                              SingleChildScrollView(
                                controller: scrollController,
                                padding: EdgeInsets.fromLTRB(
                                    30.w, 20.h, 30.w, 100.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đánh giá từ khách hàng',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    if (widget
                                            .destinationData.userRatingsTotal >
                                        0) ...[
                                      // Hiển thị đánh giá tổng quan
                                      Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  widget.destinationData.rating
                                                      .toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 32.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Row(
                                                  children:
                                                      List.generate(5, (index) {
                                                    return Icon(
                                                      index <
                                                              widget
                                                                  .destinationData
                                                                  .rating
                                                                  .round()
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 16.sp,
                                                    );
                                                  }),
                                                ),
                                                SizedBox(height: 5.h),
                                                Text(
                                                  '${widget.destinationData.userRatingsTotal} đánh giá',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 20.w),
                                            Expanded(
                                              child: Text(
                                                'Địa điểm này nhận được đánh giá tích cực từ cộng đồng du lịch.',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                    ],
                                    // Placeholder cho danh sách đánh giá chi tiết
                                    Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.rate_review,
                                            size: 48.sp,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 16.h),
                                          Text(
                                            'Chưa có đánh giá chi tiết',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'Đánh giá chi tiết sẽ được hiển thị ở đây\nkhi tích hợp với Places API',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Photo tab
                              SingleChildScrollView(
                                controller: scrollController,
                                padding:
                                    EdgeInsets.fromLTRB(10.w, 0.h, 10.w, 100.h),
                                child: MasonryGridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  itemCount:
                                      widget.destinationData.photo.length,
                                  itemBuilder: (context, index) {
                                    return Hero(
                                      tag: widget.destinationData.photo[index],
                                      child: CachedImage(
                                        imageUrl:
                                            widget.destinationData.photo[index],
                                        borderRadius: 16,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MediaDetailView(
                                                mediaUrl: widget.destinationData
                                                    .photo[index],
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
                                padding: EdgeInsets.fromLTRB(
                                    30.w, 20.h, 30.w, 100.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Video về địa điểm',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    if (widget
                                        .destinationData.video.isNotEmpty) ...[
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount:
                                            widget.destinationData.video.length,
                                        itemBuilder: (context, index) =>
                                            VideoThumbnail(
                                          videoUrl: widget
                                              .destinationData.video[index],
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaDetailView(
                                                  mediaUrl: widget
                                                      .destinationData
                                                      .video[index],
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
                                            Icon(
                                              Icons.videocam_off,
                                              size: 48.sp,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 16.h),
                                            Text(
                                              'Chưa có video',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              'Video về địa điểm này sẽ được hiển thị ở đây\nkhi có dữ liệu từ Places API',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[500],
                                              ),
                                            ),
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
                    padding: EdgeInsets.fromLTRB(30.w, 0.h, 30.w, 20.h),
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
