import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/rental_vehicle/vehicle_rental_detail_screen.dart';
import 'package:tourguideapp/views/service/rental_vehicle/vehicle_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';

class VehicleCardData {
  final String model;
  final String seats;
  final String vehicleId;
  final String vehicleRegisterId;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String rentOption;
  final double hour4Price;
  final double hour8Price;
  final double dayPrice;
  final List<String> requirements;
  final String vehicleType;
  final String vehicleColor;
  final String pickupLocation;

  VehicleCardData({
    required this.model,
    required this.seats,
    required this.vehicleId,
    required this.vehicleRegisterId,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.rentOption,
    required this.hour4Price,
    required this.hour8Price,
    required this.dayPrice,
    required this.requirements,
    required this.vehicleType,
    required this.vehicleColor,
    required this.pickupLocation,
  });
}

class VehicleCard extends StatelessWidget {
  final VehicleCardData data;

  const VehicleCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<RentalVehicleViewModel>(context, listen: false);

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
        padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.model,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Consumer<RentalVehicleViewModel>(
                  builder: (context, viewModel, child) {
                    return FutureBuilder<String>(
                      future: viewModel.getVehiclePhoto(data.vehicleId),
                      builder: (context, snapshot) {
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
                                    if (loadingProgress == null) return child;
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
                                  errorBuilder: (context, error, stackTrace) {
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
                        return Text(
                          viewModel.getDisplayVehicleType(data.vehicleType,
                              Localizations.localeOf(context).languageCode),
                          style: TextStyle(
                              fontSize: 14.sp, color: const Color(0xFF7D848D)),
                        );
                      }),
                      SizedBox(width: 6.w),
                      Text(
                        '|',
                        style: TextStyle(
                            fontSize: 14.sp, color: const Color(0xFF7D848D)),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${data.seats} ${AppLocalizations.of(context).translate('seats')}",
                        style: TextStyle(
                            fontSize: 14.sp, color: const Color(0xFF7D848D)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    (() {
                      if (kDebugMode) {
                        print("rentOption: ${data.rentOption}");
                      } // Debug print
                      return data.rentOption == 'Hourly'
                          ? "${AppLocalizations.of(context).formatPrice(data.hour4Price)} ₫ / ${AppLocalizations.of(context).translate('hour')}"
                          : "${AppLocalizations.of(context).formatPrice(data.dayPrice)} ₫ / ${AppLocalizations.of(context).translate('day')}";
                    })(),
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFFFF7029),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 75.w,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Consumer<RentalVehicleViewModel>(
                                          builder: (context, viewModel, child) {
                                    return VehicleDetailScreen(
                                      model: data.model,
                                      imagePath: '',
                                      vehicleId: data.vehicleId,
                                      hour4Price: data.hour4Price,
                                      hour8Price: data.hour8Price,
                                      dayPrice: data.dayPrice,
                                      requirements: data.requirements,
                                      vehicleType:
                                          viewModel.getDisplayVehicleType(
                                              data.vehicleType,
                                              Localizations.localeOf(context)
                                                  .languageCode),
                                      vehicleColor: data.vehicleColor,
                                      startDate: data.startDate,
                                      endDate: data.endDate,
                                      rentOption: data.rentOption,
                                      pickupLocation: '',
                                    );
                                  }),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF007BFF),
                              side: const BorderSide(color: Color(0xFF007BFF)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                            ),
                            child: Text(
                              AppLocalizations.of(context).translate("Detail"),
                              style: TextStyle(
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 75.w,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleRentalDetail(
                                    model: data.model,
                                    imagePath: '',
                                    startDate: data.startDate,
                                    endDate: data.endDate,
                                    rentOption: data.rentOption,
                                    pickupLocation: data.pickupLocation,
                                    price: data.price,
                                    vehicleId: data.vehicleId,
                                    vehicleRegisterId: data.vehicleRegisterId,
                                    hour4Price: data.hour4Price,
                                    hour8Price: data.hour8Price,
                                    dayPrice: data.dayPrice,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                            ),
                            child: Text(
                              AppLocalizations.of(context).translate("Rent"),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
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
