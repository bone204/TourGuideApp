import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart'; 
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/destination_route_card.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
import 'package:provider/provider.dart';

class TravelRouteScreen extends StatefulWidget {
  final String routeTitle;
  final DateTime startDate;
  final DateTime endDate;
  final String provinceName;
  final int routeIndex;
  
  const TravelRouteScreen({
    super.key,
    required this.routeTitle,
    required this.startDate,
    required this.endDate,
    required this.provinceName,
    required this.routeIndex,
  });

  @override
  _TravelRouteScreenState createState() => _TravelRouteScreenState();
}

class _TravelRouteScreenState extends State<TravelRouteScreen> {
  final RouteViewModel _routeViewModel = RouteViewModel();
  late List<String> categories;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    int numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    
    categories = List.generate(numberOfDays, (index) {
      return (index + 1) == 1 ? 'Day 1' : 'Day ${index + 1}';
    });
    
    selectedCategory = categories.first;
    
    print('Tìm kiếm địa điểm cho tỉnh: ${widget.provinceName}'); // Debug log
    _routeViewModel.fetchDestinationsByProvince(widget.provinceName);
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.routeTitle,
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 20.h, 
            left: 20.w, 
            right: 20.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySelector(categories: categories, selectedCategory: selectedCategory, onCategorySelected: onCategorySelected),
              SizedBox(height: 20.h),
              Expanded(
                child: AnimatedBuilder(
                  animation: _routeViewModel,
                  builder: (context, child) {
                    if (_routeViewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_routeViewModel.error.isNotEmpty) {
                      return Center(child: Text(_routeViewModel.error));
                    }

                    if (_routeViewModel.destinations.isEmpty) {
                      return const Center(child: Text('Không có địa điểm nào'));
                    }

                    return ListView.builder(
                      itemCount: _routeViewModel.getDestinationsForRoute(widget.routeIndex).length,
                      itemBuilder: (context, index) {
                        final destination = _routeViewModel.getDestinationsForRoute(widget.routeIndex)[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: DestinationRouteCard(
                            name: destination.destinationName,
                            imagePath: destination.photo.isNotEmpty 
                                ? destination.photo[0] 
                                : 'assets/img/bg_route_1.png',
                            timeRange: '${8 + index}:00 AM - ${9 + index}:00 AM',
                            onTap: () {
                              if (kDebugMode) {
                                print('Destination tapped: ${destination.destinationName}');
                                print('Address: ${destination.specificAddress}');
                                print('Description: ${destination.descriptionViet}');
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  final routeViewModel = Provider.of<RouteViewModel>(context, listen: false);
                  routeViewModel.saveSelectedRoute(
                    routeTitle: widget.routeTitle,
                    destinations: _routeViewModel.getDestinationsForRoute(widget.routeIndex),
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                    provinceName: widget.provinceName,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailScreen(
                        routeTitle: widget.routeTitle,
                        destinations: _routeViewModel.getDestinationsForRoute(widget.routeIndex),
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Choose This Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
