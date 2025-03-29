import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import '../../viewmodels/personInfo_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_combo_box.dart';
import '../../widgets/custom_phone_field.dart';
import '../../widgets/date_time_picker.dart';

class EditPersonInfoScreen extends StatefulWidget {
  const EditPersonInfoScreen({super.key});

  @override
  _EditPersonInfoScreenState createState() => _EditPersonInfoScreenState();
}

class _EditPersonInfoScreenState extends State<EditPersonInfoScreen> {
  final List<String> _countryCodes = ['+84', '+1', '+44', '+91'];
  final Map<String, String> genderTranslations = {
    'Nam': 'Male',
    'Nữ': 'Female',
    'Khác': 'Other',
  };

  final Map<String, String> nationalityTranslations = {
    'Việt Nam': 'Vietnamese',
    'Mỹ': 'American',
    'Anh': 'British',
    'Trung Quốc': 'Chinese',
    'Nhật Bản': 'Japanese',
    'Hàn Quốc': 'Korean',
  };



  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonInfoViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Edit Information"),
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          TextButton(
            onPressed: () async {
              await viewModel.saveData();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              AppLocalizations.of(context).translate("Done"),
              style: TextStyle(
                color: AppColors.green,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                  fontSize: 12.sp,
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomComboBox(
                          hintText: AppLocalizations.of(context).translate("Gender"),
                          value: viewModel.currentGender,
                          items: Localizations.localeOf(context).languageCode == 'vi'
                              ? const ['Nam', 'Nữ', 'Khác']
                              : const ['Male', 'Female', 'Other'],
                          onChanged: (value) {
                            if (Localizations.localeOf(context).languageCode == 'vi') {
                              viewModel.gender = value;
                              viewModel.genderController.text = value ?? '';
                            } else {
                              String? vietnameseValue = viewModel.genderTranslations.entries
                                  .firstWhere((entry) => entry.value == value,
                                      orElse: () => const MapEntry('', ''))
                                  .key;
                              viewModel.gender = vietnameseValue;
                              viewModel.genderController.text = vietnameseValue;
                            }
                            setState(() {});
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomComboBox(
                          hintText: AppLocalizations.of(context).translate("Nationality"),
                          value: viewModel.currentNationality,
                          items: Localizations.localeOf(context).languageCode == 'vi'
                              ? const ['Việt Nam', 'Mỹ', 'Anh', 'Trung Quốc', 'Nhật Bản', 'Hàn Quốc']
                              : const ['Vietnamese', 'American', 'British', 'Chinese', 'Japanese', 'Korean'],
                          onChanged: (value) {
                            if (Localizations.localeOf(context).languageCode == 'vi') {
                              viewModel.nationality = value;
                              viewModel.nationalityController.text = value ?? '';
                            } else {
                              String? vietnameseValue = viewModel.nationalityTranslations.entries
                                  .firstWhere((entry) => entry.value == value,
                                      orElse: () => const MapEntry('', ''))
                                  .key;
                              viewModel.nationality = vietnameseValue;
                              viewModel.nationalityController.text = vietnameseValue;
                            }
                            setState(() {});
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
                  fontSize: 12.sp,
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
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: AppLocalizations.of(context).translate("Address"),
                controller: viewModel.addressController,
              ),
              SizedBox(height: 16.h),
              DateTimePicker(
                selectedDate: viewModel.birthdayController.text.isNotEmpty 
                  ? DateFormat('dd/MM/yyyy').parse(viewModel.birthdayController.text)
                  : DateTime.now(),
                onDateSelected: (DateTime date) {
                  viewModel.birthdayController.text = DateFormat('dd/MM/yyyy').format(date);
                },
                title: "Birthday",
              ),
            ],
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
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        CustomPhoneField(
          controller: viewModel.phoneNumberController,
          selectedCountryCode: viewModel.selectedCountryCode,
          countryCodes: _countryCodes,
          onCountryCodeChanged: (newCode) {
            viewModel.selectedCountryCode = newCode;
          },
          hintText: AppLocalizations.of(context).translate('Phone Number'),
        ),
      ],
    );
  }
}