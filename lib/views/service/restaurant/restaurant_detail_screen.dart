import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/restaurant/table_list_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_like_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
//import 'package:tourguideapp/widgets/restaurant_card.dart';
import 'package:intl/intl.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final CooperationModel restaurant;

  const RestaurantDetailScreen({
    required this.restaurant,
    Key? key,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late CooperationModel restaurant;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    restaurant = widget.restaurant;
  }

  @override
  Widget build(BuildContext context) {
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
                  image: NetworkImage(restaurant.photo),
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
                        // Restaurant Name
                        Padding(
                          padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
                          child: Text(
                            restaurant.name,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Address
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
                                  restaurant.address,
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
                                restaurant.averageRating.toString(),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14.sp),
                              ),
                              SizedBox(width: 10.w),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < restaurant.averageRating.floor()
                                        ? Icons.star
                                        : (index < restaurant.averageRating
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
                            Tab(text: 'Menu'),
                            Tab(text: 'Photo'),
                            Tab(text: 'Review'),
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
                                  child: Text(
                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14.sp),
                                  ),
                                ),
                                // Menu
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildMenuItem('Phở', 50000),
                                      _buildMenuItem('Bún bò', 55000),
                                      _buildMenuItem('Cơm tấm', 45000),
                                      _buildMenuItem('Bánh mì', 25000),
                                    ],
                                  ),
                                ),
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
                                        restaurant.photo,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                                // Reviews
                                const Center(
                                    child: Text("Reviews coming soon")),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Back and Like buttons
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
                    isLiked:
                        favouriteViewModel.isRestaurantFavourite(restaurant),
                    onLikeChanged: (value) {
                      favouriteViewModel.toggleFavouriteRestaurant(restaurant);
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
                text: isVietnamese ? "Đặt Bàn" : "Book Table",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TableListScreen(restaurant: restaurant)));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String name, double price) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
            ),
          ),
          Text(
            '${currencyFormat.format(price)} ₫',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
