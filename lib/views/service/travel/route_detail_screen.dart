import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/models/destination_model.dart';
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

  const RouteDetailScreen({
    Key? key,
    required this.routeTitle,
    required this.destinations,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late List<String> categories;
  late String selectedCategory;
  DateTime currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    int numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    
    categories = List.generate(numberOfDays, (index) {
      return (index + 1) == 1 ? 'Day 1' : 'Day ${index + 1}';
    });
    
    selectedCategory = categories.first;

    // Cập nhật thời gian mỗi giây
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
                  itemCount: widget.destinations.length + 1,
                  itemBuilder: (context, index) {
                    if (index == widget.destinations.length) {
                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Cancel Route',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to cancel this route?',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(
                                            'No',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Provider.of<RouteViewModel>(context, listen: false).clearSelectedRoute();
                                            Navigator.pop(context); // Đóng dialog
                                            Navigator.pop(context); // Quay lại màn hình trước
                                          },
                                          child: Text(
                                            'Yes',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 48.h,
                                margin: EdgeInsets.only(bottom: 16.h, right: 8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Route added successfully!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                height: 48.h,
                                margin: EdgeInsets.only(bottom: 16.h, left: 8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add',
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
                        ],
                      );
                    }

                    final destination = widget.destinations[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: DestinationRouteCard(
                        name: destination.destinationName,
                        imagePath: destination.photo.isNotEmpty 
                            ? destination.photo[0] 
                            : 'assets/images/default.jpg',
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
      ),
    );
  }
} 