import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/vehicle_card.dart';
import 'package:tourguideapp/widgets/vehicle_card_list.dart';
import 'package:tourguideapp/widgets/category_selector.dart'; // Import the CategorySelector widget

class CarRentalScreen extends StatefulWidget {
  const CarRentalScreen({Key? key}) : super(key: key);

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  String selectedCategory = 'Car';
  final List<String> categories = ['Car', 'Motobike', 'Bicycle'];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1)); // Ngày kết thúc mặc định là 1 ngày sau

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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'Car Rental',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(width: 88.w), 
                ],
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
                          });
                        },
                        title: "Start Date",
                      ),
                      SizedBox(width: 15.w),
                      DateTimePicker(
                        selectedDate: endDate,
                        onDateSelected: (date) {
                          setState(() {
                            endDate = date;
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('Filter'),
                              style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, 
                              maxLines: 1,
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.search, size: 24.sp, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  )
                ]
              ),
            ),
            SizedBox(height: 10.h),
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
            imagePath: 'assets/img/icon-cx3.png', // Corrected path
          ),
          VehicleCardData(
            model: 'GLA 250 SUV',
            transmission: 'Automatic',
            seats: '7 seats',
            fuelType: 'Diesel',
            imagePath: 'assets/img/icon-cx3.png', // Corrected path
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
          ),
          VehicleCardData(
            model: 'Yamaha MT-07',
            transmission: 'Manual',
            seats: '2 seats',
            fuelType: 'Petrol',
            imagePath: 'assets/img/icon-cx3.png',
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
          ),
          VehicleCardData(
            model: 'Specialized Tarmac SL7',
            transmission: 'Manual',
            seats: '1 seat',
            fuelType: 'Human',
            imagePath: 'assets/img/icon-cx3.png',
          ),
        ];
      default:
        return [];
    }
  }
}
