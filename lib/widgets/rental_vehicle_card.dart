import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';
import 'package:tourguideapp/views/my_vehicle/my_vehicle_detail_screen.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:provider/provider.dart';

class RentalVehicleCard extends StatelessWidget {
  final RentalVehicleModel vehicle;

  const RentalVehicleCard({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  Widget _buildActionButton(BuildContext context) {
    return Consumer<RentalVehicleViewModel>(
      builder: (context, viewModel, child) {
        final locale = Localizations.localeOf(context).languageCode;
        final status = viewModel.getDisplayStatus(vehicle.status, locale);
        
        return SizedBox(
          width: 100.w,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              disabledBackgroundColor: AppColors.secondaryColor,
              disabledForegroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context).translate(status),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      height: 140.h,
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
                    vehicle.vehicleModel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Consumer<RentalVehicleViewModel>(
                  builder: (context, viewModel, child) {
                    if (kDebugMode) {
                      print("VehicleId from rental vehicle: ${vehicle.vehicleId}");
                    }
                    return FutureBuilder<String>(
                      future: viewModel.getVehiclePhoto(vehicle.vehicleId),
                      builder: (context, snapshot) {
                        if (kDebugMode) {
                          print("Loading photo for vehicleId: ${vehicle.vehicleId}");
                          if (snapshot.hasError) {
                            print("Error loading photo: ${snapshot.error}");
                            print("Stack trace: ${snapshot.stackTrace}");
                          }
                        }
                        
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final imagePath = snapshot.data ?? 'assets/img/car_default.png';
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: imagePath.startsWith('assets/')
                              ? Image.asset(
                                  imagePath,
                                  height: 70.h,
                                  width: 130.w,
                                  fit: BoxFit.fill,
                                )
                              : Image.network(
                                  imagePath,
                                  height: 70.h,
                                  width: 130.w,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / 
                                              loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    if (kDebugMode) {
                                      print("Error loading image: $error");
                                      print("Stack trace: $stackTrace");
                                    }
                                    return Image.asset(
                                      'assets/img/car_default.png',
                                      height: 70.h,
                                      width: 130.w,
                                      fit: BoxFit.fill,
                                    );
                                  },
                                ),
                        );
                      },
                    );
                  },
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
                      Consumer<RentalVehicleViewModel>(
                        builder: (context, viewModel, child) {
                          final locale = Localizations.localeOf(context).languageCode;
                          return Text(
                            viewModel.getDisplayVehicleType(vehicle.vehicleType, locale),
                            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                          );
                        }
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${vehicle.maxSeats} ${AppLocalizations.of(context).translate('seats')}",
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "${AppLocalizations.of(context).formatPrice(vehicle.dayPrice)} ₫ / ${AppLocalizations.of(context).translate('day')}",
                    style: TextStyle(fontSize: 16.sp, color: const Color(0xFFFF7029), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 70.w,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyVehicleDetailScreen(vehicle: vehicle),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(color: AppColors.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate("Detail"),
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _buildActionButton(context),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
} 