import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/rental/vehicle_rental_detail_screen.dart';
import 'package:tourguideapp/views/service/rental/vehicle_detail_screen.dart';

class VehicleCardData {
  final String model;
  final String transmission;
  final String seats;
  final String fuelType;
  final String imagePath;
  final DateTime startDate; 
  final DateTime endDate; 

  VehicleCardData({
    required this.model,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.imagePath,
    required this.startDate, 
    required this.endDate
  });
}

class VehicleCard extends StatelessWidget {
  final VehicleCardData data;

  const VehicleCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Text(
                    data.model.length > 11 ? '${data.model.substring(0, 11)}...' : data.model,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  child: Image.asset(
                    data.imagePath,
                    height: 70.h,
                    width: 130.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.transmission,
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        data.seats,
                        style: TextStyle(fontSize: 14.sp,color: const Color(0xFF7D848D)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "500,000 ₫ / ngày",
                    style: TextStyle(fontSize: 16.sp, color: const Color(0xFFFF7029), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleDetailScreen(
                                model: data.model,
                                imagePath: data.imagePath,
                              ),
                            ),
                          );
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF007BFF),
                          side: const BorderSide(color: Color(0xFF007BFF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate("Detail"),
                          style: TextStyle(
                            fontSize: 14.sp,
                          )
                        )
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleRentalDetail(
                                model: data.model,
                                imagePath: data.imagePath,
                                startDate: data.startDate, 
                                endDate: data.endDate, 
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate("Rent"),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          )
                        )
                      ),
                  ],)
              ],),
            )
          ],
        ),
      ),
    );
  }
}
