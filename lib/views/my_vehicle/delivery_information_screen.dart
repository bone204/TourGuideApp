import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'dart:io';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';

class DeliveryInformationScreen extends StatefulWidget {
  final String billId;
  final String vehicleRegisterId;

  const DeliveryInformationScreen({
    Key? key,
    required this.billId,
    required this.vehicleRegisterId,
  }) : super(key: key);

  @override
  State<DeliveryInformationScreen> createState() =>
      _DeliveryInformationScreenState();
}

class _DeliveryInformationScreenState extends State<DeliveryInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedTime;
  String _citizenFrontPath = '';
  String _citizenBackPath = '';
  String _handoverPhotoPath = '';
  String? _citizenFrontPhotoUrl;
  String? _citizenBackPhotoUrl;
  String? _handoverPhotoUrl;
  bool _isLoading = false;

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
                        AppLocalizations.of(context)
                            .translate('Renter Information'),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                ImagePickerWidget(
                  title: AppLocalizations.of(context)
                      .translate('Identification Photo (Front)'),
                  initialImagePath: _citizenFrontPath,
                  onImagePicked: (String path) {
                    setState(() {
                      _citizenFrontPath = path;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                ImagePickerWidget(
                  title: AppLocalizations.of(context)
                      .translate('Identification Photo (Back)'),
                  initialImagePath: _citizenBackPath,
                  onImagePicked: (String path) {
                    setState(() {
                      _citizenBackPath = path;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                ImagePickerWidget(
                  title: AppLocalizations.of(context)
                      .translate('Handover of Vehicle Photo'),
                  initialImagePath: _handoverPhotoPath,
                  onImagePicked: (String path) {
                    setState(() {
                      _handoverPhotoPath = path;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                Divider(height: 1.h),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              // Upload ảnh CCCD mặt trước
                              _citizenFrontPhotoUrl = await context
                                  .read<RentalVehicleViewModel>()
                                  .uploadVehiclePhoto(
                                    File(_citizenFrontPath),
                                    widget.billId,
                                    'citizen_front',
                                  );
                            
                              // Upload ảnh CCCD mặt sau
                              _citizenBackPhotoUrl = await context
                                  .read<RentalVehicleViewModel>()
                                  .uploadVehiclePhoto(
                                    File(_citizenBackPath),
                                    widget.billId,
                                    'citizen_back',
                                  );
                            
                              // Upload ảnh giao xe
                              _handoverPhotoUrl = await context
                                  .read<RentalVehicleViewModel>()
                                  .uploadVehiclePhoto(
                                    File(_handoverPhotoPath),
                                    widget.billId,
                                    'handover',
                                  );
                            
                              // Cập nhật thông tin giao xe và ảnh vào BILL
                              await context
                                  .read<RentalVehicleViewModel>()
                                  .updateDeliveryInfo(
                                    widget.billId,
                                    _addressController.text,
                                    _selectedTime ?? '',
                                    _noteController.text,
                                    _citizenFrontPhotoUrl ?? '',
                                    _citizenBackPhotoUrl ?? '',
                                    _handoverPhotoUrl ?? '',
                                  );

                              if (mounted) {
                                // Pop hai lần để thoát cả màn hình delivery và màn hình trước đó
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Đã cập nhật thông tin giao xe thành công'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: Size(343.w, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Gửi',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
