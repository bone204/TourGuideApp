import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/widgets/vehicle_card.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/models/vehicle_information_model.dart';

class VehicleListScreen extends StatelessWidget {
  final String selectedCategory;
  final DateTime startDate;
  final DateTime endDate;
  final String rentOption;
  final double minBudget;
  final double maxBudget;
  final Map<String, String> locationDetails;

  const VehicleListScreen({
    Key? key,
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
    required this.rentOption,
    required this.minBudget,
    required this.maxBudget,
    required this.locationDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra ngôn ngữ hiện tại và tạo chuỗi `availableText`
    String availableText;
    if (Localizations.localeOf(context).languageCode == 'vi') {
      availableText =
          '${AppLocalizations.of(context).translate(selectedCategory)} ${AppLocalizations.of(context).translate("Available")}';
    } else {
      availableText =
          '${AppLocalizations.of(context).translate("Available")} ${AppLocalizations.of(context).translate(selectedCategory)}';
    }

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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).translate('Vehicle List'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, top: 20.h),
            child: Text(
              availableText,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: StreamBuilder<List<RentalVehicleModel>>(
              stream:
                  Provider.of<RentalVehicleViewModel>(context, listen: false)
                      .getAvailableVehicles(
                selectedCategory,
                rentOption,
                minBudget,
                maxBudget,
                startDate,
                endDate,
                locationDetails,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final vehicles = snapshot.data ?? [];
                if (vehicles.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('No vehicles available'),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return FutureBuilder<VehicleInformationModel>(
                      future: Provider.of<RentalVehicleViewModel>(context,
                              listen: false)
                          .getVehicleInformation(vehicle.vehicleTypeId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final vehicleInfo = snapshot.data!;
                        return VehicleCard(
                          data: VehicleCardData(
                            model: vehicleInfo.model,
                            seats: '${vehicleInfo.seatingCapacity}',
                            vehicleId: vehicle.vehicleTypeId,
                            licensePlate: vehicle.licensePlate,
                            startDate: startDate,
                            endDate: endDate,
                            price: _getPrice(rentOption, vehicle),
                            rentOption: rentOption,
                            hour4Price: vehicle.hour4Price,
                            hour8Price: vehicle.hour8Price,
                            dayPrice: vehicle.dayPrice,
                            requirements: vehicle.requirements,
                            vehicleType: vehicle.vehicleTypeId,
                            vehicleColor: vehicleInfo.color,
                            pickupLocation: locationDetails['province'] ?? '',
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getPrice(String rentOption, RentalVehicleModel vehicle) {
    switch (rentOption) {
      case '4 Hours':
        return vehicle.hour4Price;
      case '8 Hours':
        return vehicle.hour8Price;
      case 'Daily':
        return vehicle.dayPrice;
      default:
        return vehicle.hour4Price;
    }
  }
}
