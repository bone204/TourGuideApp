import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';

class MyVehicleSettingsScreen extends StatelessWidget {
  final RentalVehicleModel vehicle;

  const MyVehicleSettingsScreen({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

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
                        AppLocalizations.of(context).translate('Vehicle Settings'),
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
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Status toggle
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('Vehicle activity status'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Consumer<RentalVehicleViewModel>(
                    builder: (context, viewModel, child) {
                      final bool isAvailable = vehicle.status == "Khả dụng";
                      final bool isUnavailable = vehicle.status == "Không khả dụng";
                      final bool canToggle = isAvailable || isUnavailable;
                      
                      return Switch(
                        value: isAvailable,
                        onChanged: canToggle
                            ? (value) async {
                                final newStatus = value ? "Khả dụng" : "Không khả dụng";
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context).translate('Confirm')),
                                    content: Text(
                                      value
                                          ? AppLocalizations.of(context)
                                              .translate('Are you sure you want to enable this vehicle?')
                                          : AppLocalizations.of(context)
                                              .translate('Are you sure you want to disable this vehicle?'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(
                                            AppLocalizations.of(context).translate('Cancel')),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text(
                                            AppLocalizations.of(context).translate('Confirm')),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await viewModel.updateVehicleStatus(
                                      vehicle.licensePlate, newStatus);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              }
                            : null,
                        activeColor: AppColors.primaryColor,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Delete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (vehicle.status == "Khả dụng" || vehicle.status == "Không khả dụng")
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context).translate('Confirm')),
                            content: Text(AppLocalizations.of(context)
                                .translate('Are you sure you want to delete this vehicle?')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child:
                                    Text(AppLocalizations.of(context).translate('Cancel')),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child:
                                    Text(AppLocalizations.of(context).translate('Delete')),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final viewModel =
                              Provider.of<RentalVehicleViewModel>(context, listen: false);
                          await viewModel.deleteVehicle(vehicle.licensePlate);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(
                  AppLocalizations.of(context).translate('Delete Vehicle'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 