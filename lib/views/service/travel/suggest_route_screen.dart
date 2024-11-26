import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/range_date_time_picker.dart';
import 'package:tourguideapp/widgets/route_card.dart';

class SuggestRouteScreen extends StatefulWidget {
  const SuggestRouteScreen({super.key});
  

  @override
  _SuggestRouteScreenState createState() => _SuggestRouteScreenState();
}

class _SuggestRouteScreenState extends State<SuggestRouteScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  final List<Map<String, dynamic>> routes = [
    {
      'name': 'by: Traveline',
      'rating': 4.5,
    },
    {
      'name': 'by: Thông Joker',
      'rating': 4.7,
    },
    {
      'name': 'by: Thông Tulen',
      'rating': 4.3,
    },
    {
      'name': 'by: Thiện Tank',
      'rating': 4.8,
    },
  ];

  // Hàm tự động tạo imagePath
  String _getImagePath(int index) {
    return 'assets/img/bg_route_${index + 1}.png';
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
                          AppLocalizations.of(context).translate('Nha Trang'),
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
          padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RangeDateTimePicker(
                startDate: _startDate,
                endDate: _endDate,
                onDateRangeSelected: (DateTimeRange range) {
                  setState(() {
                    _startDate = range.start;
                    _endDate = range.end;
                  });
                },
              ),
              SizedBox(height: 20.h),
              Text(
                  AppLocalizations.of(context).translate('Suggested Route'),
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: RouteCard(
                        name: routes[index]['name'],
                        imagePath: _getImagePath(index), // Tự động tạo imagePath
                        rating: routes[index]['rating'],
                        onTap: () {
                          // Xử lý khi tap vào route
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
