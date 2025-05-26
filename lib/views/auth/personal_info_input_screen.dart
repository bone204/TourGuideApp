import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';
import 'package:tourguideapp/widgets/birthday_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/views/auth/hobbies_selection_screen.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final String phoneNumber;

  const PersonalInfoScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  String? _selectedGender;
  String? _selectedNationality;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> nationalities = [
    'Vietnamese',
    'American',
    'British',
    'Chinese',
    'Japanese',
    'Korean',
    // Add more nationalities as needed
  ];

  final Map<String, String> genderTranslations = {
    'Male': 'Nam',
    'Female': 'Nữ',
    'Other': 'Khác',
  };

  final Map<String, String> nationalityTranslations = {
    'Vietnamese': 'Việt Nam',
    'American': 'Mỹ',
    'British': 'Anh',
    'Chinese': 'Trung Quốc',
    'Japanese': 'Nhật Bản',
    'Korean': 'Hàn Quốc',
  };

  // Hàm chuyển đổi giá trị sang tiếng Việt để lưu lên Firebase
  String _getVietnameseValue(String? englishValue, Map<String, String> translations) {
    return englishValue != null ? translations[englishValue] ?? englishValue : '';
  }

  // Hàm lấy giá trị hiển thị theo ngôn ngữ của app

  bool _validateInputs() {
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_selectedNationality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your nationality'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthday'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // Hàm để lấy danh sách đã được dịch
  List<String> _getTranslatedList(List<String> originalList, Map<String, String> translations) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'vi') {
      return originalList.map((item) => translations[item] ?? item).toList();
    }
    return originalList;
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách đã được dịch
    final translatedGenders = _getTranslatedList(genders, genderTranslations);
    final translatedNationalities = _getTranslatedList(nationalities, nationalityTranslations);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 88.h, 20.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  AppLocalizations.of(context).translate('Personal Information'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).translate('Please fill in your personal information'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  AppLocalizations.of(context).translate('Full Name'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: AppLocalizations.of(context).translate('Full Name'),
                  controller: _fullNameController,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).translate('Gender'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomComboBox(
                  hintText: AppLocalizations.of(context).translate('Gender'),
                  value: _selectedGender != null 
                    ? (Localizations.localeOf(context).languageCode == 'vi' 
                        ? genderTranslations[_selectedGender] 
                        : _selectedGender)
                    : null,
                  items: translatedGenders,
                  onChanged: (value) {
                    setState(() {
                      // Lưu giá trị tiếng Anh
                      _selectedGender = Localizations.localeOf(context).languageCode == 'vi'
                          ? genderTranslations.entries
                              .firstWhere((entry) => entry.value == value,
                                  orElse: () => const MapEntry('', ''))
                              .key
                          : value;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).translate('Nationality'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomComboBox(
                  hintText: AppLocalizations.of(context).translate('Nationality'),
                  value: _selectedNationality != null 
                    ? (Localizations.localeOf(context).languageCode == 'vi' 
                        ? nationalityTranslations[_selectedNationality] 
                        : _selectedNationality)
                    : null,
                  items: translatedNationalities,
                  onChanged: (value) {
                    setState(() {
                      // Lưu giá trị tiếng Anh
                      _selectedNationality = Localizations.localeOf(context).languageCode == 'vi'
                          ? nationalityTranslations.entries
                              .firstWhere((entry) => entry.value == value,
                                  orElse: () => const MapEntry('', ''))
                              .key
                          : value;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                BirthdayDatePicker(
                  selectedDate: _selectedDate,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  title: 'Birthday',
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: _isLoading 
                    ? null
                    : () async {
                        if (_validateInputs()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HobbiesSelectionScreen(
                                email: widget.email,
                                password: widget.password,
                                username: widget.username,
                                phoneNumber: widget.phoneNumber,
                                fullName: _fullNameController.text,
                                gender: _getVietnameseValue(_selectedGender, genderTranslations),
                                nationality: _getVietnameseValue(_selectedNationality, nationalityTranslations),
                                birthday: DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              ),
                            ),
                          );
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    minimumSize: Size(double.infinity, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context).translate('Continue'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 