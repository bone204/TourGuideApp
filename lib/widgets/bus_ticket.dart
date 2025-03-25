import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_ticket_detail.dart';

class BusTicket extends StatelessWidget {
  final String fromLocation;
  final String toLocation;
  final DateTime arrivalDate;
  final DateTime? returnDate;

  const BusTicket({
    Key? key,
    required this.fromLocation,
    required this.toLocation,
    required this.arrivalDate,
    this.returnDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusTicketDetail(
              arrivalDate: arrivalDate,
              returnDate: returnDate,
              fromLocation: fromLocation,
              toLocation: toLocation,
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
                      "22:00",
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
                        "8 giờ 5 phút",
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
                          "06:05",
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
                    "Dak Lak",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Bến xe An Sương",
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
                        '23 chỗ trống',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "285.000đ",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
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