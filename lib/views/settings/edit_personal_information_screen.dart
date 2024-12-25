import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
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

  String _getDisplayValue(String vietnameseValue, Map<String, String> translations) {
    if (Localizations.localeOf(context).languageCode == 'vi') {
      return vietnameseValue;
    }
    return translations[vietnameseValue] ?? vietnameseValue;
  }

  String _getVietnameseValue(String? englishValue, Map<String, String> translations) {
    if (Localizations.localeOf(context).languageCode == 'vi') {
      return englishValue ?? '';
    }
    return translations.entries
        .firstWhere((entry) => entry.value == englishValue,
            orElse: () => const MapEntry('', ''))
        .key;
  }

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
                            AppLocalizations.of(context).translate("Confirm"),
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 12.sp,
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
                            value: viewModel.gender != null && viewModel.gender!.isNotEmpty
                                ? (Localizations.localeOf(context).languageCode == 'vi' 
                                    ? viewModel.gender 
                                    : genderTranslations[viewModel.gender])
                                : null,
                            items: Localizations.localeOf(context).languageCode == 'vi'
                                ? const ['Nam', 'Nữ', 'Khác']
                                : const ['Male', 'Female', 'Other'],
                            onChanged: (value) {
                              if (Localizations.localeOf(context).languageCode == 'vi') {
                                viewModel.gender = value;
                                viewModel.genderController.text = value ?? '';
                              } else {
                                String? vietnameseValue = genderTranslations.entries
                                    .firstWhere((entry) => entry.value == value,
                                        orElse: () => const MapEntry('', ''))
                                    .key;
                                viewModel.gender = vietnameseValue;
                                viewModel.genderController.text = vietnameseValue;
                              }
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
                            value: viewModel.nationality != null && viewModel.nationality!.isNotEmpty
                                ? (Localizations.localeOf(context).languageCode == 'vi'
                                    ? viewModel.nationality
                                    : nationalityTranslations[viewModel.nationality])
                                : null,
                            items: Localizations.localeOf(context).languageCode == 'vi'
                                ? const ['Việt Nam', 'Mỹ', 'Anh', 'Trung Quốc', 'Nhật Bản', 'Hàn Quốc']
                                : const ['Vietnamese', 'American', 'British', 'Chinese', 'Japanese', 'Korean'],
                            onChanged: (value) {
                              if (Localizations.localeOf(context).languageCode == 'vi') {
                                viewModel.nationality = value;
                                viewModel.nationalityController.text = value ?? '';
                              } else {
                                String? vietnameseValue = nationalityTranslations.entries
                                    .firstWhere((entry) => entry.value == value,
                                        orElse: () => const MapEntry('', ''))
                                    .key;
                                viewModel.nationality = vietnameseValue;
                                viewModel.nationalityController.text = vietnameseValue;
                              }
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
                DateTimePicker(
                  selectedDate: viewModel.birthdayController.text.isNotEmpty 
                    ? DateFormat('dd/MM/yyyy').parse(viewModel.birthdayController.text)
                    : DateTime.now(),
                  onDateSelected: (DateTime date) {
                    viewModel.birthdayController.text = DateFormat('dd/MM/yyyy').format(date);
                  },
                  title: "Birthday",
                  rentOption: "Daily",
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