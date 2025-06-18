import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';
import 'package:tourguideapp/views/my_vehicle/my_vehicle_detail_screen.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/views/my_vehicle/renter_information_screen.dart';
//import 'package:tourguideapp/views/my_vehicle/my_vehicle_settings_screen.dart';
import 'package:tourguideapp/models/vehicle_information_model.dart';

class RentalVehicleCard extends StatelessWidget {
  final RentalVehicleModel vehicle;

  const RentalVehicleCard({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  Widget _buildActionButton(BuildContext context) {
    return Consumer<RentalVehicleViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          width: 65.w,
          child: ElevatedButton(
            onPressed: vehicle.status == 'Chờ duyệt' ||
                    vehicle.status == 'Không sử dụng'
                ? null // Disable button
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RenterInformationScreen(
                            vehicleRegisterId: vehicle.licensePlate,
                            vehicleStatus: vehicle.status),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  vehicle.status == 'Chờ duyệt' ? Colors.grey : Colors.white,
              foregroundColor: vehicle.status == 'Chờ duyệt'
                  ? Colors.white
                  : AppColors.primaryColor,
              side: BorderSide(
                color: vehicle.status == 'Chờ duyệt'
                    ? Colors.grey
                    : AppColors.primaryColor,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                vehicle.status == 'Chờ duyệt'
                    ? AppLocalizations.of(context).translate('Pending')
                    : vehicle.status == 'Không sử dụng'
                        ? AppLocalizations.of(context).translate('Disabled')
                        : AppLocalizations.of(context).translate('For Rent'),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VehicleInformationModel>(
      future: Provider.of<RentalVehicleViewModel>(context, listen: false)
          .getVehicleInformation(vehicle.vehicleTypeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final vehicleInfo = snapshot.data!;
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
                          vehicleInfo.model,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Consumer<RentalVehicleViewModel>(
                        builder: (context, viewModel, child) {
                          if (kDebugMode) {
                            print(
                                "VehicleId from rental vehicle: ${vehicle.vehicleTypeId}");
                          }
                          return FutureBuilder<String>(
                            future:
                                viewModel.getVehiclePhoto(vehicle.vehicleTypeId),
                            builder: (context, snapshot) {
                              if (kDebugMode) {
                                print(
                                    "Loading photo for vehicleId: ${vehicle.vehicleTypeId}");
                                if (snapshot.hasError) {
                                  print(
                                      "Error loading photo: ${snapshot.error}");
                                  print("Stack trace: ${snapshot.stackTrace}");
                                }
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final imagePath =
                                  snapshot.data ?? 'assets/img/car_default.png';
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
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          if (kDebugMode) {
                                            print(
                                                "Error loading image: $error");
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
                            Text(vehicleInfo.brand),
                            Text('${vehicleInfo.seatingCapacity} chỗ'),
                            Text(vehicleInfo.color),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "${AppLocalizations.of(context).formatPrice(vehicle.dayPrice)} ₫ / ${AppLocalizations.of(context).translate('day')}",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFFFF7029),
                                fontWeight: FontWeight.w700),
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
                                      builder: (context) =>
                                          MyVehicleDetailScreen(
                                              vehicle: vehicle),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryColor,
                                  side: const BorderSide(
                                      color: AppColors.primaryColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.r)),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Detail"),
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
      },
    );
  }
}
