import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/checkbox_row.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/image_picker.dart';

class VehicleRentalRegisterScreen extends StatefulWidget {
  const VehicleRentalRegisterScreen({super.key});

  @override
  _VehicleRentalRegisterScreenState createState() => _VehicleRentalRegisterScreenState();
}

class _VehicleRentalRegisterScreenState extends State<VehicleRentalRegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false];

  // Variables for dropdown selections
  String _selectedBusinessType = 'Type 1';
  String _selectedBusinessRegion = 'Region 1';
  String _selectedBankName = 'Bank 1';

  void _nextStep() {
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

  void _handleTitleTap() {
    // Logic bạn muốn thực hiện khi nhấn vào tiêu đề
    if (kDebugMode) {
      print('Title tapped!');
    }
  }

  void _completeRegistration() {
    // Logic để hoàn thành đăng ký
    if (kDebugMode) {
      print('Registration completed!');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);
    return SafeArea(
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
                          AppLocalizations.of(context).translate('My Vehicle'),
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
                                AppLocalizations.of(context).translate('Identification Information'),
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
                                AppLocalizations.of(context).translate("Tax Information"),
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
                                AppLocalizations.of(context).translate("Billing Information"),
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
                      return Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Full Name',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Email',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Phone Number',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Identification Number',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                const ImagePickerWidget(title: 'Identification Photo'),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (index == 1) {
                      return Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdown(
                                  label: 'Business Type',
                                  items: ['Type 1', 'Type 2', 'Type 3'],
                                  selectedItem: _selectedBusinessType,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBusinessType = newValue!;
                                    });
                                  },
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Business Name',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildDropdown(
                                  label: 'Business Province Region',
                                  items: ['Region 1', 'Region 2', 'Region 3'],
                                  selectedItem: _selectedBusinessRegion,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBusinessRegion = newValue!;
                                    });
                                  },
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Business Address',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Tax Code',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                const ImagePickerWidget(title: 'Business Register Photo'),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (index == 2) {
                      return Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Bank Account Number',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: TextEditingController(),
                                  label: 'Bank Account Name',
                                  isEditing: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildDropdown(
                                  label: 'Bank Name',
                                  items: ['Bank 1', 'Bank 2', 'Bank 3'],
                                  selectedItem: _selectedBankName,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBankName = newValue!;
                                    });
                                  },
                                ),
                                SizedBox(height: 26.h),
                                CheckboxRow(
                                  title: 'I confirm all data provided is accurate and truthful. I have read and agree to ',
                                  link: "Traveline's Privacy Policy.",
                                  onTitleTap: _handleTitleTap,
                                ),
                                SizedBox(height: 12.h),
                                CheckboxRow(
                                  title: 'I have read and commit that my vehicle meets all ',
                                  link: "Legal Requirements for rental.",
                                  onTitleTap: _handleTitleTap,
                                ),
                                SizedBox(height: 12.h),
                                CheckboxRow(
                                  title: 'I agree to the commission rate applied by the application - 20% and the ',
                                  link: "Terms Of Use.",
                                  onTitleTap: _handleTitleTap,
                                ),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        ),
                      );
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
    );
  }
}

Widget _buildTextField({required TextEditingController controller, required String label, required bool isEditing}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12.h),
      SizedBox(
        width: double.infinity,
        child: TextField(
          enabled: isEditing,
          controller: controller,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7F9),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
          ),
        ),
      ),
    ],
  );
}

Widget _buildDropdown({
  required String label,
  required List<String> items,
  required String selectedItem,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12.h),
      SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          value: selectedItem,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7F9),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
          ),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          icon: const Icon(CupertinoIcons.chevron_down),
        ),
      ),
    ],
  );
}
