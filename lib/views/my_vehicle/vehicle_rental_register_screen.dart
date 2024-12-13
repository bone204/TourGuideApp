import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/user_model.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';
import 'package:tourguideapp/widgets/checkbox_row.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/models/bank_model.dart';
import 'package:tourguideapp/viewmodels/bank_viewmodel.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';

class VehicleRentalRegisterScreen extends StatefulWidget {
  const VehicleRentalRegisterScreen({super.key});

  @override
  _VehicleRentalRegisterScreenState createState() => _VehicleRentalRegisterScreenState();
}

class _VehicleRentalRegisterScreenState extends State<VehicleRentalRegisterScreen> {
  final Map<String, dynamic> contractData = {};
  PageController _pageController = PageController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false];
  bool _isContractRegistered = false;

  // Variables for dropdown selections
  String _selectedBusinessType = 'Type 1';
  String? _selectedBankId;
  List<BankModel> _banks = [];

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

  // Thêm biến để lưu danh sách tỉnh
  List<Province> _provinces = [];
  String? _selectedProvinceId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
    _loadProvinces();
    _loadBanks();
    
    // Thêm dòng này để load thông tin xe
    final viewModel = Provider.of<RentalVehicleViewModel>(context, listen: false);
    viewModel.loadVehicleInformation('Car', 'vi'); // hoặc 'Motorbike' tùy loại xe
  }

  // Thêm hàm load danh sách tỉnh
  Future<void> _loadProvinces() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PROVINCE')
          .get();
      
      setState(() {
        _provinces = snapshot.docs
            .map((doc) => Province.fromMap({
                  ...doc.data(),
                  'provinceId': doc.id,
                }))
            .toList();
        
        // Tự động chọn tỉnh đầu tiên nếu có dữ liệu
        if (_provinces.isNotEmpty) {
          _selectedProvinceId = _provinces.first.provinceId;
          contractData['businessProvinceId'] = _selectedProvinceId;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading provinces: $e');
      }
    }
  }

  Future<void> _loadBanks() async {
    try {
      final bankViewModel = Provider.of<BankViewModel>(context, listen: false);
      await bankViewModel.loadBanks();
      setState(() {
        _banks = bankViewModel.banks;
        if (_banks.isNotEmpty) {
          _selectedBankId = _banks.first.bankId;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading banks: $e');
      }
    }
  }

  void _loadUserData() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Truy vấn Firestore để lấy thông tin người dùng
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('USER')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        // Chuyển đổi dữ liệu từ Firestore thành UserModel
        UserModel currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        // Cập nhật các TextEditingController với thông tin người dùng
        _fullNameController.text = currentUser.fullName;
        _emailController.text = currentUser.email;
        _phoneNumberController.text = currentUser.phoneNumber;
        _citizenIdController.text = currentUser.citizenId;
      } else {
        if (kDebugMode) {
          print('User document does not exist');
        }
      }
    } else {
      if (kDebugMode) {
        print('No user is currently signed in');
      }
    }
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep == 0 && (_citizenPhotoFrontPath.isEmpty || _citizenPhotoBackPath.isEmpty)) {
        _showErrorDialog(AppLocalizations.of(context).translate('Please upload both front and back photos of your identification.'));
        return;
      }
      if (_currentStep == 1 && _businessRegisterPhotoPath.isEmpty) {
        _showErrorDialog(AppLocalizations.of(context).translate('Please upload the business register photo.'));
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
    if (kDebugMode) {
      print('Title tapped!');
    }
  }

  void _completeRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Kiểm tra xem đã chọn đủ ảnh chưa
      if (_citizenPhotoFrontPath.isEmpty || 
          _citizenPhotoBackPath.isEmpty || 
          _businessRegisterPhotoPath.isEmpty) {
        _showErrorDialog(AppLocalizations.of(context)
            .translate('Please upload all required photos'));
        return;
      }

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        final contractViewModel = Provider.of<ContractViewModel>(context, listen: false);
        final currentUserId = authViewModel.currentUserId;

        if (currentUserId != null) {
          // Lấy tên ngân hàng từ bankId đã chọn
          final selectedBank = _banks.firstWhere(
            (bank) => bank.bankId == _selectedBankId,
            orElse: () => _banks.first,
          );

          // Lấy tên tỉnh từ ID đã chọn
          final selectedProvince = _provinces.firstWhere(
            (p) => p.provinceId == _selectedProvinceId,
            orElse: () => _provinces.first,
          );

          // Cập nhật contractData với tất cả thông tin cần thiết
          contractData.addAll({
            'businessType': _selectedBusinessType,
            'businessName': _businessNameController.text,
            'businessProvince': selectedProvince.provinceName,
            'businessAddress': _businessAddressController.text,
            'taxCode': _taxCodeController.text,
            'contractTerm': '1 year',
            'contractStatus': 'Pending Approval',
            // Thêm thông tin ngân hàng
            'bankName': selectedBank.bankName,
            'bankAccountNumber': _bankAccountNumberController.text,
            'bankAccountName': _bankAccountNameController.text,
          });

          await contractViewModel.createContractForUser(currentUserId, contractData);

          Navigator.of(context).pop(); // Đóng loading indicator
          Navigator.of(context).pop(); // Quay lại màn hình trước
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorDialog('Có lỗi xảy ra khi tạo hợp đồng. Vui lòng thử lại.');
        if (kDebugMode) {
          print("Lỗi khi tạo hợp đồng: $e");
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
                hintText: AppLocalizations.of(context).translate("Enter your full name"),
                label: AppLocalizations.of(context).translate("Full Name"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your full name");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _emailController,
                hintText: AppLocalizations.of(context).translate("Enter your email"),
                label: AppLocalizations.of(context).translate("Email"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your email");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _phoneNumberController,
                hintText: AppLocalizations.of(context).translate("Enter your phone number"),
                label: AppLocalizations.of(context).translate("Phone Number"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your phone number");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _citizenIdController,
                hintText: AppLocalizations.of(context).translate("Enter your identification number"),
                label: AppLocalizations.of(context).translate("Identification Number"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your identification number");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Identification (Front Photo)"),
                initialImagePath: _citizenPhotoFrontPath,
                onImagePicked: (String path) {
                  setState(() {
                    _citizenPhotoFrontPath = path;
                    contractData['citizenFrontPhoto'] = File(path);
                  });
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Identification (Back Photo)"),
                initialImagePath: _citizenPhotoBackPath,
                onImagePicked: (String path) {
                  setState(() {
                    _citizenPhotoBackPath = path;
                    contractData['citizenBackPhoto'] = File(path);
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
                items: [
                  AppLocalizations.of(context).translate("Individual"),
                  AppLocalizations.of(context).translate("Company"),
                  AppLocalizations.of(context).translate("Business Household")
                ],
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
                hintText: AppLocalizations.of(context).translate("Enter business name"),
                label: AppLocalizations.of(context).translate("Business Name"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your business name");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              SizedBox(height: 16.h),
              _buildDropdown(
                label: AppLocalizations.of(context).translate("Business Province Region"),
                items: _provinces.map((p) => p.provinceName).toList(),
                selectedItem: _provinces
                    .firstWhere(
                      (p) => p.provinceId == _selectedProvinceId,
                      orElse: () => _provinces.isNotEmpty ? _provinces.first : Province(
                        provinceId: '',
                        provinceName: '',
                        city: '',
                        district: [],
                        imageUrl: Province.defaultImageUrl,
                        rating: 0,
                      ),
                    )
                    .provinceName,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedProvinceId = _provinces
                          .firstWhere((p) => p.provinceName == newValue)
                          .provinceId;
                      contractData['businessProvinceId'] = _selectedProvinceId;
                      contractData['businessProvinceName'] = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _businessAddressController,
                label: AppLocalizations.of(context).translate("Business Address"),
                hintText: AppLocalizations.of(context).translate("Enter business address"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your business address");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _taxCodeController,
                hintText: AppLocalizations.of(context).translate("Enter tax code"),
                label: AppLocalizations.of(context).translate("Tax Code"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your tax code");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Business Register Photo"),
                initialImagePath: _businessRegisterPhotoPath,
                onImagePicked: (String path) {
                  setState(() {
                    _businessRegisterPhotoPath = path;
                    contractData['businessRegisterPhoto'] = File(path);
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
              _buildDropdown(
                label: AppLocalizations.of(context).translate("Bank Name"),
                items: _banks.map((bank) => "${bank.bankName} - ${bank.bankSubName}").toList(),
                selectedItem: "${_banks
                    .firstWhere(
                      (b) => b.bankId == _selectedBankId,
                      orElse: () => _banks.isNotEmpty ? _banks.first : BankModel(
                        bankId: '',
                        bankName: '',
                        bankSubName: '',
                      ),
                    )
                    .bankName} - ${_banks
                    .firstWhere(
                      (b) => b.bankId == _selectedBankId,
                      orElse: () => _banks.isNotEmpty ? _banks.first : BankModel(
                        bankId: '',
                        bankName: '',
                        bankSubName: '',
                      ),
                    )
                    .bankSubName}",
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      final bankName = newValue.split(' - ')[0];
                      _selectedBankId = _banks
                          .firstWhere((b) => b.bankName == bankName)
                          .bankId;
                      contractData['bankId'] = _selectedBankId;
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _bankAccountNumberController,
                hintText: AppLocalizations.of(context).translate("Enter bank account number"),
                label: AppLocalizations.of(context).translate("Bank Account Number"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your bank account number");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _bankAccountNameController,
                hintText: AppLocalizations.of(context).translate("Enter bank account name"),
                label: AppLocalizations.of(context).translate("Bank Account Name"),
                isEditing: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate("Please enter your bank account name");
                  }
                  return null;
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

Widget _buildTextField({required TextEditingController controller, required String label, required String hintText, required bool isEditing, required Function(String?) validator}) {
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
      CustomTextField(
        controller: controller,
        hintText: hintText,
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
      CustomComboBox(
        hintText: label,
        value: selectedItem,
        items: items,
        onChanged: onChanged,
      ),
    ],
  );
}


