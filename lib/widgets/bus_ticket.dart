import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_booking_bloc.dart/bus_booking_bloc.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_ticket_detail.dart';

class BusTicket extends StatelessWidget {
  final String fromLocation;
  final String toLocation;
  final DateTime departureDate;
  final DateTime? returnDate;

  const BusTicket({
    Key? key,
    required this.fromLocation,
    required this.toLocation,
    required this.departureDate,
    this.returnDate,
  }) : super(key: key);

  // Phương thức để tính thời gian và giá dựa trên tuyến đường
  Map<String, dynamic> _getRouteInfo() {
    // Thời gian và giá cho các tuyến đường khác nhau
    final routeInfo = {
      'Ho Chi Minh City': {
        'Dak Lak': {
          'departureTime': '22:00',
          'arrivalTime': '06:05',
          'duration': '8 giờ 5 phút',
          'price': 285000,
          'availableSeats': 23,
        },
        'Da Lat': {
          'departureTime': '20:00',
          'arrivalTime': '04:30',
          'duration': '8 giờ 30 phút',
          'price': 320000,
          'availableSeats': 18,
        },
        'Nha Trang': {
          'departureTime': '21:00',
          'arrivalTime': '05:00',
          'duration': '8 giờ',
          'price': 280000,
          'availableSeats': 25,
        },
      },
      'Dak Lak': {
        'Ho Chi Minh City': {
          'departureTime': '20:00',
          'arrivalTime': '04:05',
          'duration': '8 giờ 5 phút',
          'price': 285000,
          'availableSeats': 20,
        },
      },
      'Da Lat': {
        'Ho Chi Minh City': {
          'departureTime': '18:00',
          'arrivalTime': '02:30',
          'duration': '8 giờ 30 phút',
          'price': 320000,
          'availableSeats': 15,
        },
      },
      'Nha Trang': {
        'Ho Chi Minh City': {
          'departureTime': '19:00',
          'arrivalTime': '03:00',
          'duration': '8 giờ',
          'price': 280000,
          'availableSeats': 22,
        },
      },
    };

    // Tìm thông tin tuyến đường
    final fromInfo = routeInfo[fromLocation];
    if (fromInfo != null && fromInfo[toLocation] != null) {
      return fromInfo[toLocation]!;
    }

    // Thông tin mặc định nếu không tìm thấy
    return {
      'departureTime': '22:00',
      'arrivalTime': '06:05',
      'duration': '8 giờ 5 phút',
      'price': 285000,
      'availableSeats': 23,
    };
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    
    final routeInfo = _getRouteInfo();
    final departureTime = routeInfo['departureTime'] as String;
    final arrivalTime = routeInfo['arrivalTime'] as String;
    final duration = routeInfo['duration'] as String;
    final price = routeInfo['price'] as int;
    final availableSeats = routeInfo['availableSeats'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => BusBookingBloc(),
              child: BusTicketDetail(
                departureDate: departureDate,
                returnDate: returnDate,
                fromLocation: fromLocation,
                toLocation: toLocation,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.25),
                blurRadius: 4.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60.w,
                    child: Text(
                      departureTime,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.location_pin, color: AppColors.orange, size: 20.sp),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        width: 2.w,
                        height: 1.h,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Column(
                    children: [
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "(Ho Chi Minh)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 4.w),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        width: 2.w,
                        height: 1.h,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Icon(Icons.location_pin, color: AppColors.primaryColor, size: 20.sp),
                  SizedBox(
                    width: 60.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          arrivalTime,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fromLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    toLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              const Divider(
                thickness: 1,
                color: AppColors.grey,
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: AppColors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        'Limousine',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.chair, size: 16.sp, color: AppColors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        '$availableSeats chỗ trống',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${price.toStringAsFixed(0)}đ",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}