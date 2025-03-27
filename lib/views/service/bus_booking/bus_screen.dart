import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_bloc.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_event.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_state.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_list.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/province_picker.dart';

class BusScreen extends StatefulWidget {
  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  DateTime departureDate = DateTime.now();
  DateTime? returnDate;
  
  bool showReturnDate = false;
  String? selectedTickets;
  final List<String> ticketOptions = ['1', '2', '3', '4', '5', '6'];

  @override
  Widget build(BuildContext context) {
    
    return BlocProvider(
      create: (context) => BusBookingBloc(),
      child: BlocBuilder<BusBookingBloc, BusBookingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context).translate('Bus Booking'),
              onBackPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ProvincePicker(
                            title: AppLocalizations.of(context).translate("From"),
                            provinceOnly: true,
                            onRegionSelected: (details) {
                              context.read<BusBookingBloc>().add(
                                SetFromLocation(details['province'] ?? '', details),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ProvincePicker(
                            title: AppLocalizations.of(context).translate("To"),
                            provinceOnly: true,
                            onRegionSelected: (details) {
                              context.read<BusBookingBloc>().add(
                                SetToLocation(details['province'] ?? '', details),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: DateTimePicker(
                            selectedDate: departureDate,
                            onDateSelected: (date) {
                              setState(() {
                                departureDate = date;
                                if (returnDate != null && returnDate!.isBefore(date)) {
                                  returnDate = date;
                                }
                              });
                            },
                            title: AppLocalizations.of(context).translate("Arrival Date"),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        if (showReturnDate)
                          Expanded(
                            child: Stack(
                              children: [
                                DateTimePicker(
                                  selectedDate: returnDate ?? departureDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      returnDate = date;
                                    });
                                  },
                                  title: AppLocalizations.of(context).translate("Return Date"),
                                  minDate: departureDate,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showReturnDate = false;
                                        returnDate = null;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4.r),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).translate("Return Date"),
                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      showReturnDate = true;
                                      returnDate = departureDate;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                          'Add Return Date',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate("Tickets"),
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.h),
                              CustomComboBox(
                                hintText: "Select",
                                value: selectedTickets,
                                items: ticketOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTickets = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        const Expanded(
                          child: SizedBox(),
                        ),
                      ],
                    ),
                    SizedBox(height: 50.h),
                    CustomElevatedButton(
                      text: "Search Tickets",
                      onPressed: () {
                        if (state.fromLocation.isEmpty || state.toLocation.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context).translate('Please select departure and arrival locations'),
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        context.read<BusBookingBloc>().add(
                          SearchBuses(
                            departureDate: departureDate,
                            returnDate: returnDate,
                            fromLocation: state.fromLocation,
                            toLocation: state.toLocation,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusListScreen(
                              departureDate: departureDate,
                              returnDate: returnDate,
                              fromLocation: state.fromLocation,
                              toLocation: state.toLocation,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
