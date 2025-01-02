import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/views/service/travel/add_destination_screen.dart';
import 'package:tourguideapp/views/service/travel/travel_screen.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/destination_route_card.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart';
import 'package:provider/provider.dart';

class RouteDetailScreen extends StatefulWidget {
  final String routeTitle;
  final List<DestinationModel> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCustomRoute;
  final String provinceName;

  const RouteDetailScreen({
    Key? key,
    required this.routeTitle,
    required this.destinations,
    required this.startDate,
    required this.endDate,
    this.isCustomRoute = false,
    required this.provinceName,
  }) : super(key: key);

  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late List<String> categories;
  late String selectedCategory;
  DateTime currentTime = DateTime.now();
  late Timer _timer;
  late List<DestinationModel> _destinations;

  @override
  void initState() {
    super.initState();
    _destinations = List<DestinationModel>.from(widget.destinations);
    
    int numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    categories = List.generate(numberOfDays, (index) {
      return (index + 1) == 1 ? 'Day 1' : 'Day ${index + 1}';
    });
    
    selectedCategory = categories.first;

    // Tự động lưu khi là custom route
    if (widget.isCustomRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<RouteViewModel>(context, listen: false).saveSelectedRoute(
            routeTitle: widget.routeTitle,
            destinations: _destinations,
            startDate: widget.startDate,
            endDate: widget.endDate,
            provinceName: widget.provinceName,
          );
        }
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  bool isRouteAlreadySaved(BuildContext context) {
    final viewModel = Provider.of<RouteViewModel>(context, listen: false);
    return viewModel.savedRoutes.any((route) => 
      route['title'] == widget.routeTitle && 
      route['provinceName'] == widget.provinceName
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            Navigator.of(context).popUntil((route) => route.isFirst);
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
                      if (widget.isCustomRoute || Provider.of<RouteViewModel>(context).savedRoutes.any((r) => r['title'] == widget.routeTitle))
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomIconButton(
                            icon: Icons.delete_outline,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Route'),
                                  content: const Text('Are you sure you want to delete this route?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<RouteViewModel>(context, listen: false)
                                          .deleteRoute(widget.routeTitle);
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            settings: const RouteSettings(name: '/travel'),
                                            builder: (context) => const TravelScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/img/calendar.png',
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _formatDateTime(currentTime),
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CategorySelector(
                categories: categories, 
                selectedCategory: selectedCategory, 
                onCategorySelected: onCategorySelected
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.isCustomRoute ? _destinations.length + 1 : _destinations.length,
                  itemBuilder: (context, index) {
                    if (widget.isCustomRoute && index == _destinations.length) {
                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final selectedDestination = await Navigator.push<DestinationModel>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddDestinationScreen(
                                      routeTitle: widget.routeTitle,
                                      currentDestinations: _destinations,
                                      provinceName: widget.provinceName,
                                    ),
                                  ),
                                );

                                if (selectedDestination != null) {
                                  setState(() {
                                    _destinations.add(selectedDestination);
                                  });

                                  Provider.of<RouteViewModel>(context, listen: false).saveSelectedRoute(
                                    routeTitle: widget.routeTitle,
                                    destinations: _destinations,
                                    startDate: widget.startDate,
                                    endDate: widget.endDate,
                                    provinceName: widget.provinceName,
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Destination added successfully!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 56.h,
                                width: 56.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final destination = _destinations[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: DestinationRouteCard(
                        name: destination.destinationName,
                        imagePath: destination.photo.isNotEmpty 
                            ? destination.photo[0] 
                            : 'assets/img/bg_route_1.png',
                        timeRange: '${8 + index}:00 AM - ${9 + index}:00 AM',
                        onTap: () {
                          // Handle destination tap
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.isCustomRoute || isRouteAlreadySaved(context) ? null : Container(
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
                  Provider.of<RouteViewModel>(context, listen: false).saveSelectedRoute(
                    routeTitle: widget.routeTitle,
                    destinations: _destinations,
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                    provinceName: widget.provinceName,
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
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