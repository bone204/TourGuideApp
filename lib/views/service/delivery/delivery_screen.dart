import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/delivery/delivery_detail_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/core/services/firebase_auth_services.dart';
import 'package:tourguideapp/models/user_model.dart';

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
  String senderName = '';
  String senderPhone = '';

  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      UserModel? currentUser = await _authService.getCurrentUserData();
      if (currentUser != null) {
        setState(() {
          senderName = currentUser.fullName;
          senderPhone = currentUser.phoneNumber;
        });
      }
    } catch (e) {
      print('Error loading current user data: $e');
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  void onPickupLocationSelected(String location, Map<String, String> details, String senderName, String senderPhone) {
    setState(() {
      selectedPickupLocation = location;
      pickupLocationDetails = details;
    });
  }

  void onDeliveryLocationSelected(String location, Map<String, String> details, String recipientName, String recipientPhone) {
    setState(() {
      selectedDeliveryLocation = location;
      deliveryLocationDetails = details;
      // Không tự động cập nhật thông tin người nhận từ địa điểm
      // this.recipientName = recipientName;
      // this.recipientPhone = recipientPhone;
      
      // Không cập nhật text controllers
      // _recipientNameController.text = recipientName;
      // _recipientPhoneController.text = recipientPhone;
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
                onLocationSelected: (location, details, name, phone) {
                  onPickupLocationSelected(location, details, senderName, senderPhone);
                },
                isDeliveryLocation: false, // Địa điểm gửi hàng
              ),
              SizedBox(height: 24.h),
              LocationPicker(
                title: AppLocalizations.of(context).translate("Delivery Location"),
                onLocationSelected: onDeliveryLocationSelected,
                isDeliveryLocation: true, // Địa điểm giao hàng
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
                  // Kiểm tra xem đã chọn đủ thông tin chưa
                  if (selectedPickupLocation.isEmpty || selectedDeliveryLocation.isEmpty || 
                      recipientName.isEmpty || recipientPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('Please fill in all required information')),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => DeliveryDetailScreen(
                        pickupLocation: selectedPickupLocation,
                        deliveryLocation: selectedDeliveryLocation,
                        recipientName: recipientName,
                        recipientPhone: recipientPhone,
                        senderName: senderName,
                        senderPhone: senderPhone,
                        pickupLocationDetails: pickupLocationDetails,
                        deliveryLocationDetails: deliveryLocationDetails,
                      )
                    )
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
