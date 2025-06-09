import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/range_date_time_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_bloc.dart';

class SuggestRouteScreen extends StatefulWidget{
  final String provinceName;

  const SuggestRouteScreen({
    super.key,
    required this.provinceName,
  });

  @override
  _SuggestRouteScreenState createState() => _SuggestRouteScreenState();
}

class _SuggestRouteScreenState extends State<SuggestRouteScreen>{
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  int _calculateNumberOfDays() {
    return _endDate.difference(_startDate).inDays + 1;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.provinceName,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
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
            CustomElevatedButton(
              text: 'Create Custom Route',
              onPressed: () async {
                final routeName = await context.read<TravelBloc>().generateRouteName();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<TravelBloc>(),
                      child: RouteDetailScreen(
                        routeName: routeName,
                        numberOfDays: _calculateNumberOfDays(),
                        provinceName: widget.provinceName,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}