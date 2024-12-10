import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'package:intl/intl.dart';

class VehicleRegisterScreen extends StatefulWidget {
  const VehicleRegisterScreen({super.key});

  @override
  _VehicleRegisterScreenState createState() => _VehicleRegisterScreenState();
}

class _VehicleRegisterScreenState extends State<VehicleRegisterScreen> {
  PageController _pageController = PageController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false];
  bool _isContractRegistered = false;

  // Variables for dropdown selections
  String _selectedVehicleType = 'Car'; 
  String _selectedMaxSeats = '5';
  String _selectedVehicleBrand = 'Toyota';
  String _selectedVehicleModel = 'S 500 Sedan';

  // Định nghĩa các TextEditingController cụ thể
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _vehicleRegistrationController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();

  String _vehicleRegistrationPhotoFrontPath = '';
  String _vehicleRegistrationPhotoBackPath = '';

  final _formKey = GlobalKey<FormState>();

  // Thêm TextEditingController mới để lưu giá trị thực
  final TextEditingController _actualPricePerHourController = TextEditingController();
  final TextEditingController _actualPricePerDayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Cập nhật listener cho giá theo giờ
    _pricePerHourController.addListener(() {
      String value = _pricePerHourController.text.replaceAll('₫', '').replaceAll(',', '').trim();
      if (value.isNotEmpty) {
        // Cập nhật giá trị thực không có định dạng
        _actualPricePerHourController.text = value;
        
        // Thêm dấu phân cách hàng nghìn
        String formattedValue = NumberFormat('#,###').format(int.tryParse(value) ?? 0);
        
        // Cập nhật giá trị hiển thị với định dạng
        _pricePerHourController.value = TextEditingValue(
          text: '$formattedValue ₫',
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });

    // Cập nhật listener cho giá theo ngày
    _pricePerDayController.addListener(() {
      String value = _pricePerDayController.text.replaceAll('₫', '').replaceAll(',', '').trim();
      if (value.isNotEmpty) {
        _actualPricePerDayController.text = value;
        
        String formattedValue = NumberFormat('#,###').format(int.tryParse(value) ?? 0);
        
        _pricePerDayController.value = TextEditingValue(
          text: '$formattedValue ₫',
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep == 1 && (_vehicleRegistrationPhotoFrontPath.isEmpty || _vehicleRegistrationPhotoBackPath.isEmpty)) {
        _showErrorDialog('Please upload both front and back photos of your vehicle registration.');
        return;
      }
      if (_currentStep < 2) {
        setState(() {
          _stepCompleted[_currentStep] = true;
          _currentStep++;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _stepCompleted[_currentStep] = false;
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }

  void _completeRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        final rentalVehicleViewModel = Provider.of<RentalVehicleViewModel>(context, listen: false);
        final currentUserId = authViewModel.currentUserId;

        if (currentUserId != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          await rentalVehicleViewModel.createRentalVehicleForUser(currentUserId, {
            'licensePlate': _licensePlateController.text,
            'vehicleRegistration': _vehicleRegistrationController.text,
            'vehicleType': _selectedVehicleType,
            'maxSeats': int.parse(_selectedMaxSeats),
            'vehicleBrand': _selectedVehicleBrand,
            'vehicleModel': _selectedVehicleModel,
            'description': _descriptionController.text,
            'vehicleRegistrationFrontPhoto': _vehicleRegistrationPhotoFrontPath,
            'vehicleRegistrationBackPhoto': _vehicleRegistrationPhotoBackPath,
            'hourPrice': double.parse(_actualPricePerHourController.text),
            'dayPrice': double.parse(_actualPricePerDayController.text),
            'requirements': _requirementController.text.split(',').map((e) => e.trim()).toList(),
            'contractId': '1',
            'status': "Pending Approval"
          });

          // Đóng loading indicator
          Navigator.of(context).pop();

          // Chuyển hướng sau khi thành công
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Đóng loading indicator nếu có lỗi
        Navigator.of(context).pop();
        
        _showErrorDialog('Có lỗi xảy ra khi tạo hợp đồng. Vui lòng thử lại.');
        if (kDebugMode) {
          print("Lỗi khi đăng ký xe cho thuê: $e");
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_isContractRegistered) {
      _pageController.dispose();
    }
    _actualPricePerHourController.dispose();
    _actualPricePerDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Scaffold(
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
                            AppLocalizations.of(context).translate('Vehicle Register'),
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
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Row(
                                children: [
                                  Container(
                                    width: 30.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      color: _currentStep >= index ? const Color(0xFF007BFF) : Colors.transparent,
                                      border: Border.all(
                                        color: _currentStep >= index ? const Color(0xFF007BFF) : Colors.grey,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _stepCompleted[index] ? Icons.check : Icons.circle,
                                        color: _currentStep >= index ? Colors.white : Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                  if (index < 2)
                                    Container(
                                      width: 97.w,
                                      height: 1.h,
                                      color: _currentStep > index ? const Color(0xFF007BFF) : Colors.grey,
                                    ),
                                ],
                              );
                            }),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80.w,
                                child: Text(
                                  AppLocalizations.of(context).translate('Car Information'),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              SizedBox(width: 42.w),
                              SizedBox(
                                width: 90.w,
                                child: Text(
                                  AppLocalizations.of(context).translate("Documentation"),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              SizedBox(width: 42.w),
                              SizedBox(
                                width: 80.w,
                                child: Text(
                                  AppLocalizations.of(context).translate("Rental Information"),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
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
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: List<Widget>.generate(
                    3,
                    (index) {
                      if (index == 0) {
                        return _buildStep1();
                      } else if (index == 1) {
                        return _buildStep2();
                      } else if (index == 2) {
                        return _buildStep3();
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _previousStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF007BFF),
                            side: const BorderSide(color: Color(0xFF007BFF)),
                            minimumSize: Size(double.infinity, 50.h),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate("Previous"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0)
                      SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentStep == 2 ? _completeRegistration : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50.h),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          _currentStep == 2 ? AppLocalizations.of(context).translate("Confirm") : AppLocalizations.of(context).translate("Next"),
                          style: TextStyle(
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
    );
  }

  Widget _buildStep1() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your license plate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle registration';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  // Phần Vehicle Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate("Vehicle Type"),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          SizedBox(
                            width: 88.w, 
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVehicleType = 'Car';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedVehicleType == 'Car' 
                                      ? AppColors.primaryColor 
                                      : AppColors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Car',
                                    style: TextStyle(
                                      color: _selectedVehicleType == 'Car' 
                                        ? AppColors.primaryColor 
                                        : AppColors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 88.w, // Giới hạn chiều rộng của nút Motorbike
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVehicleType = 'Motorbike';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedVehicleType == 'Motorbike' 
                                      ? AppColors.primaryColor 
                                      : AppColors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Motorbike',
                                    style: TextStyle(
                                      color: _selectedVehicleType == 'Motorbike' 
                                        ? AppColors.primaryColor 
                                        : AppColors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  // Phần Max Seats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate("Max Seats"),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CustomComboBox(
                          value: _selectedMaxSeats,
                          hintText: AppLocalizations.of(context).translate("Select max seats"),
                          items: const ['1', '2', '3', '4', '5'],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMaxSeats = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Vehicle Brand"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              CustomComboBox(
                value: _selectedVehicleBrand,
                hintText: AppLocalizations.of(context).translate("Select vehicle brand"),
                items: const ['Toyota', 'Mazda', 'Vinfast'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVehicleBrand = newValue!;
                  });
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Vehicle Model"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              CustomComboBox(
                value: _selectedVehicleModel,
                hintText: AppLocalizations.of(context).translate("Select vehicle model"),
                items: const ['S 500 Sedan', 'Hehe', 'Hihi'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVehicleModel = newValue!;
                  });
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Description"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _descriptionController,
                hintText: AppLocalizations.of(context).translate("Enter description"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Vehicle Registration Photo (Front)"),
                initialImagePath: _vehicleRegistrationPhotoFrontPath,
                onImagePicked: (String url) {
                  setState(() {
                    _vehicleRegistrationPhotoFrontPath = url;
                  });
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Vehicle Registration Photo (Back)"),
                initialImagePath: _vehicleRegistrationPhotoBackPath,
                onImagePicked: (String url) {
                  setState(() {
                    _vehicleRegistrationPhotoBackPath = url;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("Price Per Hour"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _pricePerHourController,
                hintText: AppLocalizations.of(context).translate("Enter price per hour"),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your hourly rental rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Price Per Day"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _pricePerDayController,
                hintText: AppLocalizations.of(context).translate("Enter price per day"),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your daily rental rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Requirements"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomExpandableTextField(
                controller: _requirementController,
                hintText: AppLocalizations.of(context).translate("Enter vehicle rental requirements"),
                minLines: 1,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


