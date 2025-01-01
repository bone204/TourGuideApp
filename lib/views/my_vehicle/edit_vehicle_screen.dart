import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'dart:io';
import 'package:tourguideapp/widgets/currency_text_field.dart';

class EditVehicleScreen extends StatefulWidget {
  final RentalVehicleModel vehicle;

  const EditVehicleScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _vehicleRegistrationController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _actualPricePerHourController = TextEditingController();
  final TextEditingController _actualPricePerDayController = TextEditingController();
  
  String _frontPhotoUrl = '';
  String _backPhotoUrl = '';
  File? _newFrontPhoto;
  File? _newBackPhoto;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _licensePlateController.text = widget.vehicle.licensePlate;
    _vehicleRegistrationController.text = widget.vehicle.vehicleRegistration;
    
    _actualPricePerHourController.text = widget.vehicle.hour4Price.toInt().toString();
    _actualPricePerHourController.text = widget.vehicle.hour8Price.toInt().toString();
    _actualPricePerDayController.text = widget.vehicle.dayPrice.toInt().toString();
    
    _requirementsController.text = widget.vehicle.requirements.join('\n');
    _frontPhotoUrl = widget.vehicle.vehicleRegistrationFrontPhoto;
    _backPhotoUrl = widget.vehicle.vehicleRegistrationBackPhoto;
  }

  Future<void> _saveChanges() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final viewModel = Provider.of<RentalVehicleViewModel>(context, listen: false);

      double hourPrice = double.parse(_actualPricePerHourController.text);
      double dayPrice = double.parse(_actualPricePerDayController.text);

      String frontPhotoUrl = _frontPhotoUrl;
      String backPhotoUrl = _backPhotoUrl;

      if (_newFrontPhoto != null) {
        await viewModel.deleteOldPhoto(_frontPhotoUrl);
        frontPhotoUrl = await viewModel.uploadVehiclePhoto(
          _newFrontPhoto!,
          widget.vehicle.vehicleRegisterId,
          'registration_front'
        );
      }

      if (_newBackPhoto != null) {
        await viewModel.deleteOldPhoto(_backPhotoUrl);
        backPhotoUrl = await viewModel.uploadVehiclePhoto(
          _newBackPhoto!,
          widget.vehicle.vehicleRegisterId,
          'registration_back'
        );
      }

      await viewModel.updateVehicleDetails(
        widget.vehicle.vehicleRegisterId,
        {
          'licensePlate': _licensePlateController.text,
          'vehicleRegistration': _vehicleRegistrationController.text,
          'hourPrice': hourPrice,
          'dayPrice': dayPrice,
          'requirements': _requirementsController.text.split('\n').where((line) => line.isNotEmpty).toList(),
          'vehicleRegistrationFrontPhoto': frontPhotoUrl,
          'vehicleRegistrationBackPhoto': backPhotoUrl,
        },
      );

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).translate('Edit Vehicle'),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _saveChanges,
                        child: Text(
                          AppLocalizations.of(context).translate('Save'),
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate("License Plate"),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _licensePlateController,
              hintText: AppLocalizations.of(context).translate("Enter license plate"),
            ),
            SizedBox(height: 24.h),

            Text(
              AppLocalizations.of(context).translate("Vehicle Registration"),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _vehicleRegistrationController,
              hintText: AppLocalizations.of(context).translate("Enter vehicle registration"),
            ),
            SizedBox(height: 24.h),

            ImagePickerWidget(
              title: AppLocalizations.of(context).translate("Vehicle Registration Photo (Front)"),
              initialImagePath: _frontPhotoUrl,
              isNetworkImage: true,
              onImagePicked: (String path) {
                setState(() {
                  _newFrontPhoto = File(path);
                });
              },
            ),
            SizedBox(height: 24.h),

            ImagePickerWidget(
              title: AppLocalizations.of(context).translate("Vehicle Registration Photo (Back)"),
              initialImagePath: _backPhotoUrl,
              isNetworkImage: true,
              onImagePicked: (String path) {
                setState(() {
                  _newBackPhoto = File(path);
                });
              },
            ),
            SizedBox(height: 24.h),

            Text(
              AppLocalizations.of(context).translate("Price Per Hour"),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            CurrencyTextField(
              controller: _pricePerHourController,
              actualController: _actualPricePerHourController,
              hintText: AppLocalizations.of(context).translate("Enter price per hour"),
            ),
            SizedBox(height: 24.h),

            Text(
              AppLocalizations.of(context).translate("Price Per Day"),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            CurrencyTextField(
              controller: _pricePerDayController,
              actualController: _actualPricePerDayController,
              hintText: AppLocalizations.of(context).translate("Enter price per day"),
            ),
            SizedBox(height: 24.h),

            Text(
              AppLocalizations.of(context).translate("Requirements"),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            CustomExpandableTextField(
              controller: _requirementsController,
              hintText: AppLocalizations.of(context).translate("Enter vehicle rental requirements"),
              minLines: 3,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vehicleRegistrationController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _requirementsController.dispose();
    _actualPricePerHourController.dispose();
    _actualPricePerDayController.dispose();
    super.dispose();
  }
} 