import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
import '../../viewmodels/personInfo_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_combo_box.dart';
import '../../widgets/custom_phone_field.dart';

class EditPersonInfoScreen extends StatefulWidget {
  const EditPersonInfoScreen({super.key});

  @override
  _EditPersonInfoScreenState createState() => _EditPersonInfoScreenState();
}

class _EditPersonInfoScreenState extends State<EditPersonInfoScreen> {
  String _selectedCountryCode = '+84';
  final List<String> _countryCodes = ['+84', '+1', '+44', '+91'];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonInfoViewModel>(context);

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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).translate('Edit Information'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await viewModel.saveData();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate("Full Name"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                CustomTextField(
                  hintText: AppLocalizations.of(context).translate("Full Name"),
                  controller: viewModel.fullnameController,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Gender"),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          CustomComboBox(
                            hintText: AppLocalizations.of(context).translate("Gender"),
                            value: viewModel.gender,
                            items: const ['Male', 'Female', 'Other'],
                            onChanged: (value) {
                              viewModel.gender = value;
                              viewModel.genderController.text = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Nationality"),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          CustomComboBox(
                            hintText: AppLocalizations.of(context).translate("Nationality"),
                            value: viewModel.nationality,
                            items: const ['Vietnamese', 'American', 'British', 'Other'],
                            onChanged: (value) {
                              viewModel.nationality = value;
                              viewModel.nationalityController.text = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).translate("Identification Number"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: AppLocalizations.of(context).translate("Identification Number"),
                  controller: viewModel.citizenIdController,
                ),
                SizedBox(height: 16.h),
                _buildPhoneNumberField(viewModel),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).translate("Address"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: AppLocalizations.of(context).translate("Address"),
                  controller: viewModel.addressController,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).translate("Birthday"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: AppLocalizations.of(context).translate("Birthday"),
                  controller: viewModel.birthdayController,
                ),
              ],
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
        CustomPhoneField(
          controller: viewModel.phoneNumberController,
          selectedCountryCode: _selectedCountryCode,
          countryCodes: _countryCodes,
          onCountryCodeChanged: (newCode) {
            setState(() {
              _selectedCountryCode = newCode;
            });
          },
          hintText: AppLocalizations.of(context).translate('Phone Number'),
        ),
      ],
    );
  }
}