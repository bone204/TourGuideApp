import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/budget_slider.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/rent_option_selector.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'vehicle_list_screen.dart';

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
  String selectedRentOption = 'Hourly';

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Column(
          children: [
            BudgetSlider(),
            SizedBox(height: 24.h),
            RentOptionSelector(
              selectedOption: selectedRentOption,
              onOptionSelected: (option) {
                setState(() {
                  selectedRentOption = option;
                });
              },
            ),
            SizedBox(height: 24.h),
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
            SizedBox(height: 24.h),
            DateTimePicker(
              selectedDate: endDate,
              onDateSelected: (date) {
                setState(() {
                  if (date.isAfter(startDate)) {
                    endDate = date;
                  } else {
                    // Show error dialog
                  }
                });
              },
              title: "End Date",
            ),
            SizedBox(height: 24.h),
            LocationPicker(),
            SizedBox(height: 50.h),
            CustomElevatedButton(
              text: "Confirm",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleListScreen(
                      selectedCategory: selectedCategory,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
