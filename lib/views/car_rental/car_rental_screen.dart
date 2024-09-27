import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarRentalScreen extends StatefulWidget {
  const CarRentalScreen({Key? key}) : super(key: key);

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  String selectedCategory = 'Car';

  @override
  Widget build(BuildContext context) {
    // Khởi tạo ScreenUtil với kích thước thiết kế
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildCategorySelector(),
            Expanded(
              child: _buildVehicleList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCategoryButton('Car'),
          _buildCategoryButton('Motobike'),
          _buildCategoryButton('Bicycle'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    bool isSelected = category == selectedCategory;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF007BFF) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF007BFF),
        side: const BorderSide(color: Color(0xFF007BFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Text(category, style: TextStyle(fontSize: 14.sp)),
    );
  }

  Widget _buildVehicleList() {
    List<Map<String, String>> vehicles = _getVehiclesForCategory(selectedCategory);
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        return _buildVehicleCard(vehicles[index]);
      },
    );
  }

  Widget _buildVehicleCard(Map<String, String> vehicle) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              vehicle['model'] ?? '',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vehicle['transmission'] ?? '', style: TextStyle(fontSize: 14.sp)),
                Text(vehicle['seats'] ?? '', style: TextStyle(fontSize: 14.sp)),
                Text(vehicle['fuelType'] ?? '', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Rent Now', style: TextStyle(fontSize: 14.sp)),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Detail', style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.explore, 'Explore', false),
          _buildNavItem(Icons.car_rental, 'Rental', true),
          _buildNavItem(Icons.person, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF007BFF) : Colors.grey,
            size: 24.sp,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF007BFF) : Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getVehiclesForCategory(String category) {
    switch (category) {
      case 'Car':
        return [
          {
            'model': 'S 500 Sedan',
            'transmission': 'Automatic',
            'seats': '5 seats',
            'fuelType': 'Diesel',
          },
          {
            'model': 'GLA 250 SUV',
            'transmission': 'Automatic',
            'seats': '7 seats',
            'fuelType': 'Diesel',
          },
        ];
      case 'Motobike':
        return [
          {
            'model': 'Honda CBR1000RR',
            'transmission': 'Manual',
            'seats': '2 seats',
            'fuelType': 'Petrol',
          },
          {
            'model': 'Yamaha MT-07',
            'transmission': 'Manual',
            'seats': '2 seats',
            'fuelType': 'Petrol',
          },
        ];
      case 'Bicycle':
        return [
          {
            'model': 'Trek Domane SL 5',
            'transmission': 'Manual',
            'seats': '1 seat',
            'fuelType': 'Human',
          },
          {
            'model': 'Specialized Tarmac SL7',
            'transmission': 'Manual',
            'seats': '1 seat',
            'fuelType': 'Human',
          },
        ];
      default:
        return [];
    }
  }
}