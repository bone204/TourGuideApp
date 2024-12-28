import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'dart:io';

class DeliveryInformationScreen extends StatefulWidget {
  const DeliveryInformationScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryInformationScreen> createState() => _DeliveryInformationScreenState();
}

class _DeliveryInformationScreenState extends State<DeliveryInformationScreen> {
  String _identificationFrontPath = '';
  String _identificationBackPath = '';
  String _handoverPhotoPath = '';
  final Map<String, dynamic> deliveryData = {};

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 17.sp,
              color: AppColors.black,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17.sp,
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
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
                        AppLocalizations.of(context).translate('Renter Information'),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagePickerWidget(
                    title: AppLocalizations.of(context).translate('Identification Photo (Front)'),
                    initialImagePath: _identificationFrontPath,
                    onImagePicked: (String path) {
                      setState(() {
                        _identificationFrontPath = path;
                        deliveryData['identificationFrontPhoto'] = File(path);
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  
                  ImagePickerWidget(
                    title: AppLocalizations.of(context).translate('Identification Photo (Back)'),
                    initialImagePath: _identificationBackPath,
                    onImagePicked: (String path) {
                      setState(() {
                        _identificationBackPath = path;
                        deliveryData['identificationBackPhoto'] = File(path);
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  
                  ImagePickerWidget(
                    title: AppLocalizations.of(context).translate('Handover of Vehicle Photo'),
                    initialImagePath: _handoverPhotoPath,
                    onImagePicked: (String path) {
                      setState(() {
                        _handoverPhotoPath = path;
                        deliveryData['handoverPhoto'] = File(path);
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  Divider(height: 1.h),
                  SizedBox(height: 24.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle send logic here
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate('Send'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 