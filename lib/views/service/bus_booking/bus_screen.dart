import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_bloc.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_event.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_state.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';

class BusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusBookingBloc(),
      child: BusScreenContent(),
    );
  }
}

class BusScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusBookingBloc, BusBookingState>(
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
                        child: LocationPicker(
                          title: AppLocalizations.of(context).translate("From"),
                          onLocationSelected: (location, details) {
                            context.read<BusBookingBloc>().add(
                              SetFromLocation(location, details),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: LocationPicker(
                          title: AppLocalizations.of(context).translate("To"),
                          onLocationSelected: (location, details) {
                            context.read<BusBookingBloc>().add(
                              SetToLocation(location, details),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50.h),
                  CustomElevatedButton(
                    text: "Search Tickets",
                    onPressed: () {
                      if (state.fromLocation.isNotEmpty && state.toLocation.isNotEmpty) {
                        context.read<BusBookingBloc>().add(SearchBusTickets());
                      }
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
