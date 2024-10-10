import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
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

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(width: 88.w), // Spacer to balance layout
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
            CategorySelector(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
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
