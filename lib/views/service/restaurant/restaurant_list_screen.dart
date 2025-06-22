import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/restaurant_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/core/services/restaurant_service.dart';
//import 'package:tourguideapp/views/service/restaurant/restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  final String? selectedProvince;
  final String? selectedSpecialty;
  final double? minBudget;
  final double? maxBudget;

  const RestaurantListScreen({
    super.key,
    this.selectedProvince,
    this.selectedSpecialty,
    this.minBudget,
    this.maxBudget,
  });

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<CooperationModel> restaurants = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      if (widget.selectedProvince != null &&
          widget.selectedProvince!.isNotEmpty) {
        restaurants = await _restaurantService
            .getRestaurantsByProvince(widget.selectedProvince!);
      } else {
        // TODO: Load all restaurants if no province selected
        restaurants = [];
      }

      // Apply filters
      if (widget.selectedSpecialty != null) {
        restaurants = _restaurantService.filterRestaurantsBySpecialty(
            restaurants, widget.selectedSpecialty!);
      }

      if (widget.minBudget != null && widget.maxBudget != null) {
        restaurants = _restaurantService.filterRestaurantsByBudget(
            restaurants, widget.minBudget!, widget.maxBudget!);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Lỗi khi tải danh sách nhà hàng: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onBackPressed: () {
          Navigator.of(context).pop();
        },
        title: AppLocalizations.of(context).translate("Restaurant List"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadRestaurants,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Không tìm thấy nhà hàng nào',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          
                          childAspectRatio: 161.w / 230.h,
                          mainAxisSpacing: 10.h,
                          crossAxisSpacing: 10.w,
                        ),
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];

                          // TODO: Tính giá bàn rẻ nhất từ dữ liệu thực tế
                          int? minTablePrice;
                          // Giả lập giá dựa trên rating
                          if (restaurant.averageRating >= 4.5) {
                            minTablePrice = 400000;
                          } else if (restaurant.averageRating >= 4.0) {
                            minTablePrice = 300000;
                          } else {
                            minTablePrice = 200000;
                          }

                          return RestaurantCard(
                            restaurant: restaurant,
                            minTablePrice: minTablePrice,
                          );
                        },
                      ),
                    ),
    );
  }
}
