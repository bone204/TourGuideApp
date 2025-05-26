import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/my_vehicle/edit_vehicle_screen.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/category_selector.dart';
import '../../models/rental_vehicle_model.dart';
import '../../widgets/disable_textfield.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late List<String> categories;
  late Stream<RentalVehicleModel> vehicleStream;

  @override
  void initState() {
    super.initState();
    // Khởi tạo stream để lắng nghe thay đổi
    vehicleStream = FirebaseFirestore.instance
        .collection('RENTAL_VEHICLE')
        .doc(widget.vehicle.vehicleRegisterId)
        .snapshots()
        .map((snapshot) => RentalVehicleModel.fromMap(snapshot.data()!));
  }

  @override
  Widget build(BuildContext context) {
    categories = [
      AppLocalizations.of(context).translate('Information'),
      AppLocalizations.of(context).translate('Documentation'), 
      AppLocalizations.of(context).translate('Rental Info')
    ];

    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return Scaffold(
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
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomIconButton(
                        icon: Icons.edit,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditVehicleScreen(
                                vehicle: widget.vehicle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<RentalVehicleModel>(
        stream: vehicleStream,
        initialData: widget.vehicle,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
    
          final updatedVehicle = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: CategorySelector(
                  categories: categories,
                  selectedCategory: AppLocalizations.of(context).translate(selectedCategory),
                  onCategorySelected: (category) {
                    setState(() {
                      if (category == AppLocalizations.of(context).translate('Information')) {
                        selectedCategory = 'Information';
                      } else if (category == AppLocalizations.of(context).translate('Documentation')) {
                        selectedCategory = 'Documentation';
                      } else {
                        selectedCategory = 'Rental Info';
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: _buildContent(updatedVehicle),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(RentalVehicleModel vehicle) {
    final numberFormat = NumberFormat('#,###');

    switch (selectedCategory) {
      case 'Information':
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("License Plate"),
                text: vehicle.licensePlate,
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Vehicle Registration"),
                text: vehicle.vehicleRegistration,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Vehicle Type"),
                      text: vehicle.vehicleType,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Max Seats"),
                      text: vehicle.maxSeats.toString(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Brand"),
                text: vehicle.vehicleBrand,
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Model"),
                text: vehicle.vehicleModel,
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Color"),
                text: vehicle.vehicleColor,
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
                fontWeight: FontWeight. w700,
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
                    vehicle.vehicleRegistrationFrontPhoto,
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
                  fontWeight: FontWeight.w700,
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
                    vehicle.vehicleRegistrationBackPhoto,
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
                      labelText: AppLocalizations.of(context).translate("Price For 4 Hour"),
                      text: '${numberFormat.format(vehicle.hour4Price)} ₫',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Price Per Day"),
                      text: '${numberFormat.format(vehicle.dayPrice)} ₫',
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
                      fontWeight: FontWeight.w700,
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
                      vehicle.requirements.join("\n"),
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
