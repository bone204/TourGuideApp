import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/delivery/delivery_detail_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String selectedPickupLocation = '';
  Map<String, String> pickupLocationDetails = {};
  String selectedDeliveryLocation = '';
  Map<String, String> deliveryLocationDetails = {};
  String recipientName = '';
  String recipientPhone = '';

  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  void onPickupLocationSelected(String location, Map<String, String> details) {
    setState(() {
      selectedPickupLocation = location;
      selectedPickupLocation = [
        details['province'],
        details['city'],
        details['district']
      ].where((s) => s != null && s.isNotEmpty).join(", ");
    });
  }

  void onDeliveryLocationSelected(String location, Map<String, String> details) {
    setState(() {
      selectedDeliveryLocation = location;
      deliveryLocationDetails = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('Fast Delivery'),
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
              LocationPicker(
                title: AppLocalizations.of(context).translate("Pickup Location"),
                onLocationSelected: onPickupLocationSelected,
              ),
              SizedBox(height: 24.h),
              LocationPicker(
                title: AppLocalizations.of(context).translate("Delivery Location"),
                onLocationSelected: onDeliveryLocationSelected,
              ),
              SizedBox(height: 24.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Recipient's Full Name"),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _recipientNameController,
                    hintText: AppLocalizations.of(context).translate("Enter recipient's full name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).translate("Please enter recipient's name");
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        recipientName = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Recipient's Phone Number"),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _recipientPhoneController,
                    hintText: AppLocalizations.of(context).translate("Enter recipient's phone number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).translate("Please enter recipient's phone number");
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        recipientPhone = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 50.h),
              CustomElevatedButton(
                text: "Confirm",
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => DeliveryDetailScreen())
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
