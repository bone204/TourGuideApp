import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/delivery/delivery_detail_screen.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/styled_textfield.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String selectedPickupLocation = '';
  String selectedDeliveryLocation = '';
  String recipientName = '';
  String recipientPhone = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onPickupLocationSelected(String location) {
    setState(() {
      selectedPickupLocation = location;
    });
  }

  void onDeliveryLocationSelected(String location) {
    setState(() {
      selectedDeliveryLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
                        AppLocalizations.of(context).translate("Fast Delivery"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocationPicker(
                title: AppLocalizations.of(context).translate("Pickup Location"),
                onProvinceSelected: onPickupLocationSelected,
              ),
              SizedBox(height: 24.h),
              LocationPicker(
                title: AppLocalizations.of(context).translate("Delivery Location"),
                onProvinceSelected: onDeliveryLocationSelected,
              ),
              SizedBox(height: 24.h),
              StyledTextField(
                title: AppLocalizations.of(context).translate("Recipient's Full Name"),
                hintText: AppLocalizations.of(context).translate("Enter recipient's full name"),
                onTextChanged: (value) {
                  setState(() {
                    recipientName = value;
                  });
                },
              ),
              SizedBox(height: 24.h),
              StyledTextField(
                title: AppLocalizations.of(context).translate("Recipient's Phone Number"),
                hintText: AppLocalizations.of(context).translate("Enter recipient's phone number"),
                onTextChanged: (value) {
                  setState(() {
                    recipientPhone = value;
                  });
                },
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
