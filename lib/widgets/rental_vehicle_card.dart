import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';
import 'package:tourguideapp/views/my_vehicle/delivery_information_screen.dart';
import 'package:tourguideapp/views/my_vehicle/my_vehicle_detail_screen.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/views/my_vehicle/renter_information_screen.dart';
import 'package:tourguideapp/views/my_vehicle/my_vehicle_settings_screen.dart';

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
        
        if (kDebugMode) {
          print("Current locale: $locale");
          print("Original status: ${vehicle.status}");
        }

        final displayStatus = viewModel.getDisplayStatus(vehicle.status, locale);
        
        if (kDebugMode) {
          print("Translated status: $displayStatus");
        }

        final bool isRentable = vehicle.status == "Cho thuê";
        final bool isTransportable = vehicle.status == "Vận chuyển";
        final bool isClickable = isRentable || isTransportable;

        if (kDebugMode) {
          print("isRentable: $isRentable");
          print("isTransportable: $isTransportable");
        }
        
        return SizedBox(
          width: 90.w,
          child: ElevatedButton(
            onPressed: isClickable 
              ? () {
                  if (isRentable) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenterInformationScreen(),
                      ),
                    );
                  } else if (isTransportable) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeliveryInformationScreen(),
                      ),
                    );
                  }
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isClickable ? AppColors.primaryColor : AppColors.secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              disabledBackgroundColor: AppColors.secondaryColor,
              disabledForegroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                displayStatus,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings,
        size: 24.sp,
        color: AppColors.black,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyVehicleSettingsScreen(vehicle: vehicle),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      height: 160.h,
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
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: 8.h),
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
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Consumer<RentalVehicleViewModel>(
                                  builder: (context, viewModel, child) {
                                    final locale = Localizations.localeOf(context).languageCode;
                                    return Text(
                                      viewModel.getDisplayVehicleType(vehicle.vehicleType, locale),
                                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text('|', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D))),
                              SizedBox(width: 4.w),
                              Text(
                                "${vehicle.maxSeats} ${AppLocalizations.of(context).translate('seats')}",
                                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.settings,
                              size: 20.sp,
                              color: AppColors.grey,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyVehicleSettingsScreen(vehicle: vehicle),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${AppLocalizations.of(context).formatPrice(vehicle.dayPrice)} ₫ / ${AppLocalizations.of(context).translate('day')}",
                        style: TextStyle(fontSize: 16.sp, color: const Color(0xFFFF7029), fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        SizedBox(
                          width: 65.w,
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
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context).translate("Detail"),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildActionButton(context),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
} 