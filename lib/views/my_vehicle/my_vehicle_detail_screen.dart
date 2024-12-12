import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/category_selector.dart';
import '../../models/rental_vehicle_model.dart';
import '../../widgets/disable_textfield.dart';
import 'package:intl/intl.dart';

class MyVehicleDetailScreen extends StatefulWidget {
  final RentalVehicleModel vehicle;
  
  const MyVehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  _MyVehicleDetailState createState() => _MyVehicleDetailState();
}

class _MyVehicleDetailState extends State<MyVehicleDetailScreen> {
  String selectedCategory = 'Information';
  final List<String> categories = ['Information', 'Documentation', 'Rental Info'];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).translate('Vehicle Detail'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: CategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildContent() {
    final locale = Localizations.localeOf(context).languageCode;
    final numberFormat = NumberFormat.currency(
      locale: locale == 'vi' ? 'vi_VN' : 'en_US',
      symbol: locale == 'vi' ? '₫' : '\$',
      decimalDigits: 0,
    );

    switch (selectedCategory) {
      case 'Information':
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("License Plate"),
                text: widget.vehicle.licensePlate,
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Vehicle Registration"),
                text: widget.vehicle.vehicleRegistration,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Vehicle Type"),
                      text: widget.vehicle.vehicleType,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Max Seats"),
                      text: widget.vehicle.maxSeats.toString(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Brand"),
                text: widget.vehicle.vehicleBrand,
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Model"),
                text: widget.vehicle.vehicleModel,
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Color"),
                text: widget.vehicle.vehicleColor,
              ),
            ],
          ),
        );
      case 'Documentation':
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("Vehicle Registration Photo (Front)"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    widget.vehicle.vehicleRegistrationFrontPhoto,
                    fit: BoxFit.cover,
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
                      return Center(
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.grey,
                          size: 40.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                AppLocalizations.of(context).translate("Vehicle Registration Photo (Back)"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    widget.vehicle.vehicleRegistrationBackPhoto,
                    fit: BoxFit.cover,
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
                      return Center(
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.grey,
                          size: 40.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      case 'Rental Info':
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Price Per Hour"),
                      text: numberFormat.format(widget.vehicle.hourPrice),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Price Per Day"),
                      text: numberFormat.format(widget.vehicle.dayPrice),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Requirements"),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      widget.vehicle.requirements.join("\n"),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
