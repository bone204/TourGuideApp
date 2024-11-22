import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';
import 'package:tourguideapp/widgets/checkbox_row.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class VehicleRentalRegisterScreen extends StatefulWidget {
  const VehicleRentalRegisterScreen({super.key});

  @override
  _VehicleRentalRegisterScreenState createState() => _VehicleRentalRegisterScreenState();
}

class _VehicleRentalRegisterScreenState extends State<VehicleRentalRegisterScreen> {
  PageController _pageController = PageController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false];
  bool _isContractRegistered = false;

  // Variables for dropdown selections
  String _selectedBusinessType = 'Type 1';
  String _selectedBusinessRegion = 'Region 1';
  String _selectedBankName = 'Bank 1';

  // Định nghĩa các TextEditingController cụ thể
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _taxCodeController = TextEditingController();
  final TextEditingController _bankAccountNumberController = TextEditingController();
  final TextEditingController _bankAccountNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _citizenIdController = TextEditingController();

  String _businessRegisterPhotoPath = '';
  String _citizenPhotoFrontPath = '';
  String _citizenPhotoBackPath = '';

  final _formKey = GlobalKey<FormState>();
  bool _isCheckbox1Checked = false;
  bool _isCheckbox2Checked = false;
  bool _isCheckbox3Checked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
  }

  void _loadUserData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final contractViewModel = Provider.of<ContractViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUserId;

    if (currentUserId != null) {
        final userData = await contractViewModel.getUserData(currentUserId);
        if (userData != null) {
            _fullNameController.text = userData['fullName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneNumberController.text = userData['phoneNumber'] ?? '';
            _citizenIdController.text = userData['citizenId'] ?? '';
        }
    } else {
        if (kDebugMode) {
            print("Người dùng không đăng nhập");
        }
    }
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep == 0 && (_citizenPhotoFrontPath.isEmpty || _citizenPhotoBackPath.isEmpty)) {
        _showErrorDialog('Please upload both front and back photos of your identification.');
        return;
      }
      if (_currentStep == 1 && _businessRegisterPhotoPath.isEmpty) {
        _showErrorDialog('Please upload the business register photo.');
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

  void _handleTitleTap() {
    // Logic bạn muốn thực hiện khi nhấn vào tiêu đề
    if (kDebugMode) {
      print('Title tapped!');
    }
  }

  void _completeRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_isCheckbox1Checked || !_isCheckbox2Checked || !_isCheckbox3Checked) {
        _showErrorDialog('Please agree to all terms and conditions.');
        return;
      }
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final contractViewModel = Provider.of<ContractViewModel>(context, listen: false);
      
      final currentUserId = authViewModel.currentUserId;

      if (currentUserId != null) {
        // Tải ảnh lên Firebase Storage và lấy URL
        if (_businessRegisterPhotoPath.isNotEmpty) {
          _businessRegisterPhotoPath = await _uploadImageToFirebase(File(_businessRegisterPhotoPath));
        }
        if (_citizenPhotoFrontPath.isNotEmpty) {
          _citizenPhotoFrontPath = await _uploadImageToFirebase(File(_citizenPhotoFrontPath));
        }
        if (_citizenPhotoBackPath.isNotEmpty) {
          _citizenPhotoBackPath = await _uploadImageToFirebase(File(_citizenPhotoBackPath));
        }

        await contractViewModel.createContractForUser(currentUserId, {
          'businessType': _selectedBusinessType,
          'businessName': _businessNameController.text,
          'businessProvince': _selectedBusinessRegion,
          'businessAddress': _businessAddressController.text,
          'taxCode': _taxCodeController.text,
          'businessRegisterPhoto': _businessRegisterPhotoPath,
          'citizenFrontPhoto': _citizenPhotoFrontPath,
          'citizenBackPhoto': _citizenPhotoBackPath,
          'contractTerm': '1 year', 
          'contractStatus': 'Pending Approval', 
        });

        if (kDebugMode) {
          print('Registration completed!');
        }

        setState(() {
          _isContractRegistered = true;
        });

        // Trả về kết quả cho MyVehicleScreen
        Navigator.of(context).pop(true);
      } else {
        if (kDebugMode) {
          print('User ID is not available.');
        }
      }
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('Photos/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Lỗi khi tải ảnh lên: $e');
      return '';
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
              _buildTextField(
                controller: _fullNameController,
                label: AppLocalizations.of(context).translate("Full Name"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _phoneNumberController,
                label: AppLocalizations.of(context).translate("Phone Number"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _citizenIdController,
                label: AppLocalizations.of(context).translate("Identification Number"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your identification number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Identification (Front Photo)"),
                initialImagePath: _citizenPhotoFrontPath,
                onImagePicked: (String url) {
                  setState(() {
                    _citizenPhotoFrontPath = url;
                  });
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Identification (Back Photo)"),
                initialImagePath: _citizenPhotoBackPath,
                onImagePicked: (String url) {
                  setState(() {
                    _citizenPhotoBackPath = url;
                    if (kDebugMode) {
                      print(_citizenPhotoBackPath);
                    }
                  });
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
              _buildDropdown(
                label: AppLocalizations.of(context).translate("Business Type"),
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
                controller: _businessNameController,
                label: AppLocalizations.of(context).translate("Business Name"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              SizedBox(height: 16.h),
              _buildDropdown(
                label: AppLocalizations.of(context).translate("Business Province Region"),
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
                controller: _businessAddressController,
                label: AppLocalizations.of(context).translate("Business Address"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _taxCodeController,
                label: AppLocalizations.of(context).translate("Tax Code"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your tax code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Business Register Photo"),
                initialImagePath: _businessRegisterPhotoPath,
                onImagePicked: (String url) {
                  setState(() {
                    _businessRegisterPhotoPath = url;
                    if (kDebugMode) {
                      print(_businessRegisterPhotoPath);
                    }
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
              _buildTextField(
                controller: _bankAccountNumberController,
                label: AppLocalizations.of(context).translate("Bank Account Number"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank account number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _bankAccountNameController,
                label: AppLocalizations.of(context).translate("Bank Account Name"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank account name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildDropdown(
                label: AppLocalizations.of(context).translate("Bank Name"),
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
                title: AppLocalizations.of(context).translate("I confirm all data provided is accurate and truthful. I have read and agree to "),
                link: AppLocalizations.of(context).translate("Traveline's Privacy Policy."),
                onTitleTap: _handleTitleTap,
                value: _isCheckbox1Checked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isCheckbox1Checked = newValue ?? false;
                  });
                },
              ),
              SizedBox(height: 12.h),
              CheckboxRow(
                title: AppLocalizations.of(context).translate("I have read and commit that my vehicle meets all "),
                link: AppLocalizations.of(context).translate("Legal Requirements for rental."),
                onTitleTap: _handleTitleTap,
                value: _isCheckbox2Checked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isCheckbox2Checked = newValue ?? false;
                  });
                },
              ),
              SizedBox(height: 12.h),
              CheckboxRow(
                title: AppLocalizations.of(context).translate("I agree to the commission rate applied by the application - 20% and the "),
                link: AppLocalizations.of(context).translate("Terms Of Use."),
                onTitleTap: _handleTitleTap,
                value: _isCheckbox3Checked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isCheckbox3Checked = newValue ?? false;
                  });
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField({required TextEditingController controller, required String label, required bool isEditing, required Function(String?) validator}) {
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
      TextFormField(
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
          suffixIcon: Icon(
            Icons.edit,
            color: const Color(0xFF5D6679),
            size: 24.sp,
          ),
        ),
        validator: (value) {
          // Đảm bảo hàm validator trả về String? (có thể là null hoặc String)
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          return null; // Trả về null nếu không có lỗi
        },
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
