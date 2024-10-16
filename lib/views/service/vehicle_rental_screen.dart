import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/vehicle_card.dart';
import 'package:tourguideapp/widgets/vehicle_card_list.dart';
import 'package:tourguideapp/widgets/category_selector.dart';

class VehicleRentalScreen extends StatefulWidget {
  const VehicleRentalScreen({Key? key}) : super(key: key);

  @override
  State<VehicleRentalScreen> createState() => _VehicleRentalScreenState();
}

class _VehicleRentalScreenState extends State<VehicleRentalScreen> {
  String selectedCategory = 'Car';
  final List<String> categories = ['Car', 'Motobike', 'Bicycle'];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1)); 

  @override
  Widget build(BuildContext context) {
    // Kiểm tra ngôn ngữ hiện tại
    String availableText;
    if (Localizations.localeOf(context).languageCode == 'vi') {
      availableText = '${AppLocalizations.of(context).translate(selectedCategory)} ${AppLocalizations.of(context).translate("Available")}';
    } else {
      availableText = '${AppLocalizations.of(context).translate("Available")} ${AppLocalizations.of(context).translate(selectedCategory)}';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                        AppLocalizations.of(context).translate('Car Rental'),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DateTimePicker(
                        selectedDate: startDate,
                        onDateSelected: (date) {
                          setState(() {
                            startDate = date;
                            if (endDate.isBefore(startDate)) {
                              endDate = startDate.add(const Duration(days: 1));
                            }
                          });
                        },
                        title: "Start Date",
                      ),
                      SizedBox(width: 12.w),
                      DateTimePicker(
                        selectedDate: endDate,
                        onDateSelected: (date) {
                          setState(() {
                            if (date.isAfter(startDate)) {
                              endDate = date;
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context).translate('Invalid End Date')),
                                    content: Text(AppLocalizations.of(context).translate('End date must be after the start date.')),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text(AppLocalizations.of(context).translate('OK')),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          });
                        },
                        title: "End Date",
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      LocationPicker(),
                      Container(
                        width: 94.w,
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007BFF),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0ff00000).withOpacity(0.25),
                              blurRadius: 4.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('Filter'),
                                style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8.w),
                              Icon(Icons.search, size: 24.sp, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ]
              ),
            ),
            CategorySelector(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                availableText, 
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: VehicleList(
                vehiclesDataList: _getVehiclesForCategory(selectedCategory), // Consistent name
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get vehicles based on the selected category
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
            endDate: endDate, // Corrected path
          ),
          VehicleCardData(
            model: 'GLA 250 SUV',
            transmission: 'Automatic',
            seats: '7 seats',
            fuelType: 'Diesel',
            imagePath: 'assets/img/icon-cx3.png',
            startDate: startDate,
            endDate: endDate, // Corrected path
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
