import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/hotel/room_list_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
//import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_like_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class HotelDetailScreen extends StatefulWidget {
  final CooperationModel hotel;

  const HotelDetailScreen({
    required this.hotel,
    Key? key,
  }) : super(key: key);

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late CooperationModel hotel;

  @override
  void initState() {
    super.initState();
    hotel = widget.hotel;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final favouriteViewModel =
        Provider.of<FavouriteDestinationsViewModel>(context);
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      body: Stack(
        children: [
          // Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(hotel.photo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content
          DraggableScrollableSheet(
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
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel Name
                        Padding(
                          padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
                          child: Text(
                            hotel.name,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Price per day
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey[600],
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  hotel.address,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Rating
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Row(
                            children: [
                              Text(
                                hotel.averageRating.toString(),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14.sp),
                              ),
                              SizedBox(width: 10.w),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < hotel.averageRating.floor()
                                        ? Icons.star
                                        : (index < hotel.averageRating
                                            ? Icons.star_half
                                            : Icons.star_border),
                                    color: Colors.amber,
                                    size: 16.sp,
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
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          tabs: const [
                            Tab(text: 'About'),
                            Tab(text: 'Review'),
                            Tab(text: 'Photo'),
                            Tab(text: 'Video'),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // TabBarView content
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: SizedBox(
                            height: 200.h,
                            child: TabBarView(
                              children: [
                                // About
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotel.introduction.isNotEmpty 
                                          ? hotel.introduction 
                                          : AppLocalizations.of(context).translate("No description available."),
                                        style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text('${AppLocalizations.of(context).translate("Address")}: ${hotel.address}', style: TextStyle(fontSize: 13.sp)),
                                      SizedBox(height: 4.h),
                                      Text('${AppLocalizations.of(context).translate("Province/City")}: ${hotel.province}', style: TextStyle(fontSize: 13.sp)),
                                      SizedBox(height: 4.h),
                                      Text('${AppLocalizations.of(context).translate("Phone number")}: ${hotel.bossPhone}', style: TextStyle(fontSize: 13.sp)),
                                      SizedBox(height: 8.h),
                                      Text('${AppLocalizations.of(context).translate("Booking count")}: ${hotel.bookingTimes}', style: TextStyle(fontSize: 13.sp)),
                                      SizedBox(height: 4.h),
                                      Text('${AppLocalizations.of(context).translate("Revenue")}: ${hotel.revenue.toStringAsFixed(0)} VNĐ', style: TextStyle(fontSize: 13.sp)),
                                      SizedBox(height: 4.h),
                                      Text('${AppLocalizations.of(context).translate("Hotel owner")}: ${hotel.bossName}', style: TextStyle(fontSize: 13.sp)),
                                      SizedBox(height: 4.h),
                                      Text('${AppLocalizations.of(context).translate("Type")}: ${hotel.type}', style: TextStyle(fontSize: 13.sp)),
                                    ],
                                  ),
                                ),
                                // Review
                                Center(child: Text(AppLocalizations.of(context).translate("Reviews coming soon"))),
                                // Photos
                                GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.network(
                                        hotel.photo,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                                // Videos
                                Center(child: Text(AppLocalizations.of(context).translate("Videos coming soon"))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 100.h), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Back and Like buttons container
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
                  CustomLikeButton(
                    isLiked: favouriteViewModel.isHotelFavourite(hotel),
                    onLikeChanged: (value) {
                      favouriteViewModel.toggleFavouriteHotel(hotel);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Book Now button
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomElevatedButton(
                text: isVietnamese ? "Đặt Ngay" : "Book Now",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoomListScreen(hotel: hotel)));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
