import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/budget_slider.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/rent_option_selector.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'vehicle_list_screen.dart';
import 'package:tourguideapp/widgets/time_picker.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';

class VehicleRentalScreen extends StatefulWidget {
  final String initialCategory;

  const VehicleRentalScreen({
    Key? key,
    required this.initialCategory,
  }) : super(key: key);

  @override
  State<VehicleRentalScreen> createState() => _VehicleRentalScreenState();
}

class _VehicleRentalScreenState extends State<VehicleRentalScreen> {
  late String selectedCategory;
  final List<String> categories = ['Car', 'Motorbike'];
  late DateTime startDate;
  late DateTime endDate;
  String selectedRentOption = 'Hourly';
  double minBudget = 0;
  double maxBudget = 1000000;
  String selectedProvince = '';
  String address = '';
  Map<String, String> locationDetails = {};
  String selectedPackage = '4 Hours';
  final List<String> hourPackages = ['4 Hours', '8 Hours'];
  TimeOfDay startTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 11, minute: 0);
  String selectedLocation = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;

    final now = DateTime.now();
    if (selectedRentOption == 'Hourly') {
      startDate = now.hour >= 12
          ? DateTime(now.year, now.month, now.day + 1)
          : DateTime(now.year, now.month, now.day);
    } else {
      startDate = now.hour >= 16
          ? DateTime(now.year, now.month, now.day + 1)
          : DateTime(now.year, now.month, now.day);
    }
    endDate = startDate.add(const Duration(days: 1));
  }

  DateTime getFirstAllowedDate() {
    final now = DateTime.now();
    if (selectedRentOption == 'Hourly') {
      return now.hour >= 12
          ? DateTime(now.year, now.month, now.day + 1)
          : DateTime(now.year, now.month, now.day);
    } else {
      return now.hour >= 16
          ? DateTime(now.year, now.month, now.day + 1)
          : DateTime(now.year, now.month, now.day);
    }
  }

  void onBudgetChanged(double min, double max) {
    setState(() {
      minBudget = min;
      maxBudget = max;
    });
  }

  void onLocationSelected(String location, Map<String, String> details) {
    setState(() {
      selectedLocation = location;
      locationDetails = details;
    });
  }

  void updateEndTime() {
    int hours = selectedPackage == '4 Hours' ? 4 : 8;
    int newHour = startTime.hour + hours;
    if (newHour >= 24) {
      newHour = newHour - 24;
    }
    endTime = TimeOfDay(hour: newHour, minute: startTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate(
            selectedCategory == 'Car' ? 'Car Rental' : 'Motorbike Rental'),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("Budget"),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 28.h),
              BudgetSlider(
                onBudgetChanged: onBudgetChanged,
                initialMin: minBudget,
                initialMax: maxBudget,
                type: selectedCategory,
              ),
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
              if (selectedRentOption == 'Hourly') ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DateTimePicker(
                        selectedDate: startDate,
                        firstDate: getFirstAllowedDate(),
                        onDateSelected: (date) {
                          setState(() {
                            startDate = date;
                          });
                        },
                        title: "Date",
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Package",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8.h),
                          CustomComboBox(
                            hintText: "Select package",
                            value: selectedPackage,
                            items: hourPackages,
                            onChanged: (value) {
                              setState(() {
                                selectedPackage = value!;
                                int hours =
                                    selectedPackage == '4 Hours' ? 4 : 8;
                                int newHour = startTime.hour + hours;
                                if (newHour >= 24) {
                                  newHour = newHour - 24;
                                }
                                endTime = TimeOfDay(
                                    hour: newHour, minute: startTime.minute);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                TimePicker(
                  startTime: startTime,
                  endTime: endTime,
                  selectedPackage: selectedPackage,
                  onStartTimeChanged: (time) {
                    setState(() {
                      startTime = time;
                      int hours = selectedPackage == '4 Hours' ? 4 : 8;
                      int newHour = time.hour + hours;
                      if (newHour >= 24) {
                        newHour = newHour - 24;
                      }
                      endTime = TimeOfDay(hour: newHour, minute: time.minute);
                    });
                  },
                ),
              ] else ...[
                DateTimePicker(
                  selectedDate: startDate,
                  firstDate: getFirstAllowedDate(),
                  onDateSelected: (date) {
                    setState(() {
                      startDate = date;
                      if (endDate.isBefore(startDate)) {
                        endDate = startDate.add(const Duration(days: 1));
                      }
                    });
                  },
                  title: "Start Date",
                  showTime: true,
                ),
                SizedBox(height: 24.h),
                DateTimePicker(
                  selectedDate: endDate,
                  onDateSelected: (date) {
                    setState(() {
                      if (date.isAfter(startDate)) {
                        endDate = date;
                      }
                    });
                  },
                  title: "End Date",
                  showTime: true,
                ),
              ],
              SizedBox(height: 24.h),
              LocationPicker(
                title: AppLocalizations.of(context).translate("Location"),
                onLocationSelected: onLocationSelected,
              ),
              SizedBox(height: 50.h),
              CustomElevatedButton(
                text: "Confirm",
                onPressed: () {
                  final DateTime finalStartDate = selectedRentOption == 'Hourly'
                      ? DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          startTime.hour,
                          startTime.minute,
                        )
                      : startDate;

                  final DateTime finalEndDate = selectedRentOption == 'Hourly'
                      ? DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          endTime.hour,
                          endTime.minute,
                        )
                      : endDate;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleListScreen(
                        selectedCategory: selectedCategory,
                        startDate: finalStartDate,
                        endDate: finalEndDate,
                        rentOption: selectedRentOption,
                        minBudget: minBudget,
                        maxBudget: maxBudget,
                        locationDetails: locationDetails,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
