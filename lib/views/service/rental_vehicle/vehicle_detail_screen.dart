import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';

class VehicleDetailScreen extends StatelessWidget {
  final String model;
  final String imagePath;
  final String vehicleId;
  final double hour4Price;
  final double hour8Price;
  final double dayPrice;
  final List<String> requirements;
  final String vehicleType;
  final String vehicleColor;
  final DateTime startDate;
  final DateTime endDate;
  final String rentOption;
  final String pickupLocation;

  const VehicleDetailScreen({
    Key? key,
    required this.model,
    required this.imagePath,
    required this.vehicleId,
    required this.hour4Price,
    required this.hour8Price,
    required this.dayPrice,
    required this.requirements,
    required this.vehicleType,
    required this.vehicleColor,
    required this.startDate,
    required this.endDate,
    required this.rentOption,
    required this.pickupLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RentalVehicleViewModel>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Text(
                        model,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
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
      body: Container(
        color: AppColors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Consumer<RentalVehicleViewModel>(
                    builder: (context, viewModel, child) {
                      return FutureBuilder<String>(
                        future: viewModel.getVehiclePhoto(vehicleId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final imagePath = snapshot.data ?? 'assets/img/car_default.png';
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: imagePath.startsWith('assets/')
                                ? Image.asset(
                                    imagePath,
                                    height: 140.h,
                                    width: 260.w,
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    imagePath,
                                    height: 140.h,
                                    width: 260.w,
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
                                      return Image.asset(
                                        'assets/img/car_default.png',
                                        height: 140.h,
                                        width: 260.w,
                                        fit: BoxFit.fill,
                                      );
                                    },
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 30.h),
                FutureBuilder<Map<String, dynamic>>(
                  future: viewModel.getVehicleDetailsById(vehicleId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return Center(child: Text(AppLocalizations.of(context).translate("Error loading vehicle details")));
                      return const Center(child: Text("Error loading vehicle details"));
                    }

                    final vehicleDetails = snapshot.data!;
                    final brand = vehicleDetails['brand'] ?? '';
                    final fuelType = vehicleDetails['fuelType'] ?? '';
                    final transmission = vehicleDetails['transmission'] ?? '';
                    final maxSpeed = vehicleDetails['maxSpeed'] ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${AppLocalizations.of(context).translate("Rate")}:",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(width: 30.w),
                            ...List.generate(5, (index) => Padding(
                              padding: EdgeInsets.only(right: 18.w),
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24.sp,
                              ),
                            )),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        DetailRow(
                          leftTitle: AppLocalizations.of(context).translate("Brand"),
                          leftContent: AppLocalizations.of(context).translate(brand),
                          rightTitle: AppLocalizations.of(context).translate("Fuel Type"),
                          rightContent: AppLocalizations.of(context).translate(fuelType),
                        ),
                        SizedBox(height: 16.h),
                        DetailRow(
                          leftTitle: AppLocalizations.of(context).translate("Transmission"),
                          leftContent: AppLocalizations.of(context).translate(transmission),
                          rightTitle: AppLocalizations.of(context).translate("Max Speed"),
                          rightContent: AppLocalizations.of(context).translate(maxSpeed),
                        ),
                        SizedBox(height: 16.h),
                        DetailRow(
                          leftTitle: AppLocalizations.of(context).translate("Price Per Day"),
                          leftContent: "${AppLocalizations.of(context).formatPrice(dayPrice)} ₫", 
                          rightTitle: AppLocalizations.of(context).translate("Price Per Hour"),
                          rightContent: "${AppLocalizations.of(context).formatPrice(hour4Price)} ₫",
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(context).translate("Requirements"),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: requirements.map((requirement) => 
                              _buildRequirementItem(requirement)
                            ).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.black,
            ),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  final String leftTitle;
  final String leftContent;
  final String rightTitle;
  final String rightContent;

  const DetailRow({
    Key? key,
    required this.leftTitle,
    required this.leftContent,
    required this.rightTitle,
    required this.rightContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailColumn(leftTitle, leftContent),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: _buildDetailColumn(rightTitle, rightContent),
        ),
      ],
    );
  }

  Widget _buildDetailColumn(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12.h),
        Container(
          width: 160.w,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}