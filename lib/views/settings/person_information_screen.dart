import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
import '../../viewmodels/personInfo_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';


// CustomIconButton(
//                           icon: viewModel.isEditing ? Icons.check : Icons.edit,
//                           onPressed: () {
//                             if (viewModel.isEditing) {
//                               viewModel.saveData();
//                             }
//                             viewModel.toggleEditing();
//                           },
//                         ),


class PersonInfoScreen extends StatefulWidget {
  const PersonInfoScreen({super.key});

  @override
  _PersonInfoScreenState createState() => _PersonInfoScreenState();
}

class _PersonInfoScreenState extends State<PersonInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid; 
      if (userId != null) {
        Provider.of<PersonInfoViewModel>(context, listen: false).loadData(); 
      }
    });
  }

  String _selectedCountryCode = '+84'; 
  final List<String> _countryCodes = ['+84', '+1', '+44', '+91'];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonInfoViewModel>(context);

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
                          AppLocalizations.of(context).translate('Personal Information'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight, 
                        child: CustomIconButton(
                          icon: viewModel.isEditing ? Icons.check : Icons.edit,
                          onPressed: () {
                            if (viewModel.isEditing) {
                              viewModel.saveData();
                            }
                            viewModel.toggleEditing();
                          },
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  _buildTextField(
                    controller: viewModel.fullnameController,
                    label: AppLocalizations.of(context).translate("Full Name"),
                    isEditing: viewModel.isEditing,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: viewModel.genderController,
                    label: AppLocalizations.of(context).translate("Gender"),
                    isEditing: viewModel.isEditing,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: viewModel.citizenIdController,
                    label: AppLocalizations.of(context).translate("Identification Number"),
                    isEditing: viewModel.isEditing,
                  ),
                  SizedBox(height: 16.h),
                  _buildPhoneNumberField(viewModel), 
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: viewModel.addressController,
                    label: AppLocalizations.of(context).translate("Address"),
                    isEditing: viewModel.isEditing,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: viewModel.nationalityController,
                    label: AppLocalizations.of(context).translate("Nationality"),
                    isEditing: viewModel.isEditing,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    controller: viewModel.birthdayController,
                    label: AppLocalizations.of(context).translate("Birthday"),
                    isEditing: viewModel.isEditing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(PersonInfoViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Phone Number'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                items: _countryCodes
                    .map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(
                            code,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ))
                    .toList(),
                onChanged: (newCode) {
                  setState(() {
                    _selectedCountryCode = newCode!;
                  });
                },
                underline: const SizedBox(),
              ),
            ),
            SizedBox(width: 10.w), 
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: TextField(
                  enabled: viewModel.isEditing,
                  controller: viewModel.phoneNumberController, 
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
                      viewModel.phoneNumberController.text.isEmpty ? Icons.warning : (viewModel.isEditing ? Icons.edit : Icons.check_sharp),
                      color: viewModel.phoneNumberController.text.isEmpty ? Colors.red : (viewModel.isEditing ? const Color(0xFF5D6679) : const Color(0xFFFF7029)),
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
              suffixIcon: Icon(
                controller.text.isEmpty ? Icons.warning : (isEditing ? Icons.edit : Icons.check_sharp),
                color: controller.text.isEmpty ? Colors.red : (isEditing ? const Color(0xFF5D6679) : const Color(0xFFFF7029)),
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


