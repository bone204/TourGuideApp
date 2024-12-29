import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/route_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/range_date_time_picker.dart';
import 'package:tourguideapp/widgets/route_card.dart';
import 'package:tourguideapp/views/service/travel/travel_route_screen.dart';

class SuggestRouteScreen extends StatefulWidget {
  final String provinceName;
  
  const SuggestRouteScreen({
    super.key,
    required this.provinceName,
  });

  @override
  _SuggestRouteScreenState createState() => _SuggestRouteScreenState();
}

class _SuggestRouteScreenState extends State<SuggestRouteScreen> {
  final RouteViewModel _routeViewModel = RouteViewModel();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

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
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.provinceName,
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
                  itemCount: _routeViewModel.routes.length,
                  itemBuilder: (context, index) {
                    final route = _routeViewModel.routes[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: RouteCard(
                        name: route['name'],
                        imagePath: _routeViewModel.getImagePath(index),
                        rating: route['rating'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TravelRouteScreen(
                                routeTitle: _routeViewModel.getDisplayTitle(route['name']),
                                startDate: _startDate,
                                endDate: _endDate,
                                provinceName: widget.provinceName,
                                routeIndex: index,
                              ),
                            ),
                          );
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
