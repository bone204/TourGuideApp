// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/views/service/travel/route_detail_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
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
      body: 
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://vj-prod-website-cms.s3.ap-southeast-1.amazonaws.com/shutterstock1391898416-1646649508378.png"),
              fit: BoxFit.cover,
            )
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), 
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconButton(icon: Icons.chevron_left, onPressed: () => Navigator.pop(context)),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.provinceName,
                            style: TextStyle(fontSize: 20.sp, color: AppColors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: SizedBox(
                          width: 48.w,
                          height: 48.h,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
                    child: RangeDateTimePicker(
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateRangeSelected: (DateTimeRange range) {
                        setState(() {
                          _startDate = range.start;
                          _endDate = range.end;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Về ${widget.provinceName}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                '${widget.provinceName} là một điểm đến tuyệt vời với nhiều danh lam thắng cảnh đẹp, văn hóa đặc sắc và ẩm thực phong phú. Nơi đây thu hút du khách bởi những cảnh quan thiên nhiên hùng vĩ, di tích lịch sử quan trọng và con người thân thiện, hiếu khách.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.white,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Text(
                                'Hãy chọn thời gian phù hợp và để chúng tôi tạo ra một lộ trình du lịch hoàn hảo cho bạn khám phá ${widget.provinceName}!',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Nút Create Custom Route ở dưới cùng
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w, bottom: 30.h),
                    child: CustomElevatedButton(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}