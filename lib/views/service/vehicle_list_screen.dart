import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/vehicle_card.dart';
import 'package:tourguideapp/widgets/vehicle_card_list.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class VehicleListScreen extends StatelessWidget {
  final String selectedCategory;
  final DateTime startDate;
  final DateTime endDate;

  const VehicleListScreen({
    Key? key,
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vehiclesDataList = _getVehiclesForCategory(selectedCategory);

    // Kiểm tra ngôn ngữ hiện tại và tạo chuỗi `availableText`
    String availableText;
    if (Localizations.localeOf(context).languageCode == 'vi') {
      availableText = '${AppLocalizations.of(context).translate(selectedCategory)} ${AppLocalizations.of(context).translate("Available")}';
    } else {
      availableText = '${AppLocalizations.of(context).translate("Available")} ${AppLocalizations.of(context).translate(selectedCategory)}';
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
                        'Vehicle List',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, top: 20.h),
            child: Text(
              availableText,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: VehicleList(
              vehiclesDataList: vehiclesDataList,
            ),
          ),
        ],
      ),
    );
  }

  List<VehicleCardData> _getVehiclesForCategory(String category) {
    switch (category) {
      case 'Car':
        return [
          VehicleCardData(
            model: 'S 500 Sedan',
            transmission: 'Automatic',
            seats: '5 seats',
            fuelType: 'Diesel',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate,
          ),
          VehicleCardData(
            model: 'GLA 250 SUV',
            transmission: 'Automatic',
            seats: '7 seats',
            fuelType: 'Diesel',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate,
          ),
        ];
      case 'Motobike':
        return [
          VehicleCardData(
            model: 'Honda CBR1000RR',
            transmission: 'Manual',
            seats: '2 seats',
            fuelType: 'Petrol',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate,
          ),
          VehicleCardData(
            model: 'Yamaha MT-07',
            transmission: 'Manual',
            seats: '2 seats',
            fuelType: 'Petrol',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate,
          ),
        ];
      case 'Bicycle':
        return [
          VehicleCardData(
            model: 'Trek Domane SL 5',
            transmission: 'Manual',
            seats: '1 seat',
            fuelType: 'Human',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate,
          ),
          VehicleCardData(
            model: 'Specialized Tarmac SL7',
            transmission: 'Manual',
            seats: '1 seat',
            fuelType: 'Human',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate,
          ),
        ];
      default:
        return [];
    }
  }
} 