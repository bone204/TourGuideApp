import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:tourguideapp/widgets/app_dialog.dart';

class VehicleRegisterScreen extends StatefulWidget {
  const VehicleRegisterScreen({super.key});

  @override
  _VehicleRegisterScreenState createState() => _VehicleRegisterScreenState();
}

class _VehicleRegisterScreenState extends State<VehicleRegisterScreen> {
  final Map<String, dynamic> vehicleData = {};
  PageController _pageController = PageController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false];
  bool _isContractRegistered = false;

  // Variables for dropdown selections
  String _selectedVehicleType = 'Ô tô';
  String? _selectedVehicleBrand;
  String? _selectedVehicleModel;
  String? _selectedVehicleColor;

  // Định nghĩa các TextEditingController cụ thể
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _pricePer4HourController = TextEditingController();
  final TextEditingController _pricePer8HourController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _vehicleRegistrationController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();

  String _vehicleRegistrationPhotoFrontPath = '';
  String _vehicleRegistrationPhotoBackPath = '';

  final _formKey = GlobalKey<FormState>();

  // Thêm TextEditingController mới để lưu giá trị thực
  final TextEditingController _actualPricePer4HourController = TextEditingController();
  final TextEditingController _actualPricePer8HourController = TextEditingController();
  final TextEditingController _actualPricePerDayController = TextEditingController();

  bool _isInitialized = false;

  void _onVehicleTypeChanged(String newType) {
    if (kDebugMode) {
      print('Vehicle type changed to: $newType');
    }
    
    setState(() {
      _selectedVehicleType = newType;
      _selectedVehicleBrand = null;
      _selectedVehicleModel = null;
      _selectedVehicleColor = null;
    });
    
    final locale = Localizations.localeOf(context).languageCode;
    Provider.of<RentalVehicleViewModel>(context, listen: false)
        .loadVehicleInformation(newType, locale);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context).languageCode;
      setState(() {
        _selectedVehicleType = locale == 'en' ? 'Car' : 'Ô tô';
      });
      Provider.of<RentalVehicleViewModel>(context, listen: false)
          .loadVehicleInformation(_selectedVehicleType, locale);
    });

    _pricePer4HourController.addListener(() {
      String value = _pricePer4HourController.text.replaceAll('₫', '').replaceAll(',', '').trim();
      if (value.isNotEmpty) {
        _actualPricePer4HourController.text = value;
        String formattedValue = NumberFormat('#,###').format(int.tryParse(value) ?? 0);
        _pricePer4HourController.value = TextEditingValue(
          text: '$formattedValue ₫',
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });

    _pricePer8HourController.addListener(() {
      String value = _pricePer8HourController.text.replaceAll('₫', '').replaceAll(',', '').trim();
      if (value.isNotEmpty) {
        _actualPricePer8HourController.text = value;
        String formattedValue = NumberFormat('#,###').format(int.tryParse(value) ?? 0);
        _pricePer8HourController.value = TextEditingValue(
          text: '$formattedValue ₫',
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    });
    
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      final locale = Localizations.localeOf(context).languageCode;
      Provider.of<RentalVehicleViewModel>(context, listen: false)
          .loadVehicleInformation(_selectedVehicleType, locale);
      _isInitialized = true;
    }
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep == 1) {
        // Kiểm tra xem cả 2 ảnh đã được chọn chưa
        if (vehicleData['vehicleRegistrationFrontPhoto'] == null || 
            vehicleData['vehicleRegistrationBackPhoto'] == null) {
          _showErrorDialog(AppLocalizations.of(context)
              .translate('Please upload both front and back photos of your vehicle registration.'));
          return;
        }
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
      if (vehicleData['vehicleRegistrationFrontPhoto'] == null || 
          vehicleData['vehicleRegistrationBackPhoto'] == null) {
        _showErrorDialog(AppLocalizations.of(context)
            .translate('Please upload both front and back photos of your vehicle registration.'));
        return;
      }

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );

        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        final rentalVehicleViewModel = Provider.of<RentalVehicleViewModel>(context, listen: false);
        final contractViewModel = Provider.of<ContractViewModel>(context, listen: false);
        final currentUserId = authViewModel.currentUserId;

        if (currentUserId != null) {
          String contractId = '1';
          if (contractViewModel.contracts.isNotEmpty) {
            contractId = contractViewModel.contracts.first.contractId;
          }

          vehicleData.addAll({
            'licensePlate': _licensePlateController.text,
            'vehicleRegistration': _vehicleRegistrationController.text,
            'vehicleType': _selectedVehicleType,
            'vehicleBrand': _selectedVehicleBrand,
            'vehicleModel': _selectedVehicleModel,
            'vehicleColor': _selectedVehicleColor,
            'hour4Price': double.parse(_actualPricePer4HourController.text),
            'hour8Price': double.parse(_actualPricePer8HourController.text),
            'dayPrice': double.parse(_actualPricePerDayController.text),
            'requirements': _requirementController.text.split(',').map((e) => e.trim()).toList(),
            'contractId': contractId,
            'status': 'Chờ duyệt'
          });

          final locale = Localizations.localeOf(context).languageCode;
          await rentalVehicleViewModel.createRentalVehicleForUser(
            currentUserId,
            vehicleData,
            locale
          );

          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorDialog('Có lỗi xảy ra khi đăng ký xe. Vui lòng thử lại.');
        if (kDebugMode) {
          print("Lỗi khi đăng ký xe cho thuê: $e");
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showAppDialog(
      context: context,
      title: 'Lỗi',
      content: message,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ĐÓNG'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (_isContractRegistered) {
      _pageController.dispose();
    }
    _actualPricePer4HourController.dispose();
    _actualPricePer8HourController.dispose();
    _actualPricePerDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: CustomAppBar(
            title: AppLocalizations.of(context).translate("Vehicle Register"),
            onBackPressed: () => Navigator.of(context).pop(),
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
                            fontWeight: FontWeight.w700,
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
                          fontWeight: FontWeight.w700,
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
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
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
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
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
              SizedBox(height: 24.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Vehicle Type"),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 88.w,
                        child: GestureDetector(
                          onTap: () => _onVehicleTypeChanged('Ô tô'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedVehicleType == 'Ô tô'
                                    ? AppColors.primaryColor
                                    : AppColors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).translate('Car'),
                                style: TextStyle(
                                  color: _selectedVehicleType == 'Ô tô'
                                      ? AppColors.primaryColor
                                      : AppColors.black,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 88.w,
                        child: GestureDetector(
                          onTap: () => _onVehicleTypeChanged('Xe máy'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedVehicleType == 'Xe máy'
                                    ? AppColors.primaryColor
                                    : AppColors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).translate('Motorbike'),
                                style: TextStyle(
                                  color: _selectedVehicleType == 'Xe máy'
                                      ? AppColors.primaryColor
                                      : AppColors.black,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
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
              SizedBox(height: 24.h),
              Text(
                AppLocalizations.of(context).translate("Vehicle Brand"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Consumer<RentalVehicleViewModel>(
                builder: (context, viewModel, child) {
                  return CustomComboBox(
                    value: _selectedVehicleBrand,
                    hintText: AppLocalizations.of(context).translate("Select vehicle brand"),
                    items: viewModel.availableBrands,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedVehicleBrand = newValue;
                        _selectedVehicleModel = null;
                        _selectedVehicleColor = null;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Vehicle Model"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Consumer<RentalVehicleViewModel>(
                builder: (context, viewModel, child) {
                  final models = _selectedVehicleBrand != null 
                      ? viewModel.getModelsForBrand(_selectedVehicleBrand!)
                      : <String>[];
                  return CustomComboBox(
                    value: _selectedVehicleModel,
                    hintText: AppLocalizations.of(context).translate("Select vehicle model"),
                    items: models,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedVehicleModel = newValue;
                        _selectedVehicleColor = null;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Vehicle Color"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Consumer<RentalVehicleViewModel>(
                builder: (context, viewModel, child) {
                  final locale = Localizations.localeOf(context).languageCode;
                  final colors = _selectedVehicleModel != null 
                      ? viewModel.getColorsForModel(_selectedVehicleModel!, locale)
                      : <String>[];
                  return CustomComboBox(
                    value: _selectedVehicleColor,
                    hintText: AppLocalizations.of(context).translate('Select vehicle color'),
                    items: colors,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedVehicleColor = newValue;
                      });
                    },
                  );
                },
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
                onImagePicked: (String path) {
                  setState(() {
                    _vehicleRegistrationPhotoFrontPath = path;
                    vehicleData['vehicleRegistrationFrontPhoto'] = File(path);
                  });
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Vehicle Registration Photo (Back)"),
                initialImagePath: _vehicleRegistrationPhotoBackPath,
                onImagePicked: (String path) {
                  setState(() {
                    _vehicleRegistrationPhotoBackPath = path;
                    vehicleData['vehicleRegistrationBackPhoto'] = File(path);
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
                AppLocalizations.of(context).translate("Price For 4 Hour"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _pricePer4HourController,
                hintText: AppLocalizations.of(context).translate("Enter price for 4 hour"),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your 4 hourly rental rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Price For 8 Hour"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _pricePer8HourController,
                hintText: AppLocalizations.of(context).translate("Enter price for 8 hour"),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your 8 hourly rental rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Price Per Day"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
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
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
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


