import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/user/settings/edit_personal_information_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import '../../../widgets/custom_icon_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonInfoScreen extends StatefulWidget {
  const PersonInfoScreen({super.key});

  @override
  _PersonInfoScreenState createState() => _PersonInfoScreenState();
}

class _PersonInfoScreenState extends State<PersonInfoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Thêm các map chuyển đổi
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

  // Hàm chuyển đổi giá trị hiển thị theo ngôn ngữ
  String _getDisplayValue(String vietnameseValue, Map<String, String> translations) {
    if (Localizations.localeOf(context).languageCode == 'vi') {
      return vietnameseValue;
    }
    return translations[vietnameseValue] ?? vietnameseValue;
  }

  // Helper function để format số điện thoại
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    
    // Danh sách mã vùng phổ biến
    final commonCodes = ['+84', '+1', '+44', '+91'];
    
    // Tìm mã vùng trong số điện thoại
    String countryCode = '+84'; // Mặc định
    String number = phoneNumber;
    
    for (String code in commonCodes) {
      if (phoneNumber.startsWith(code)) {
        countryCode = code;
        number = phoneNumber.substring(code.length);
        break;
      }
    }
    
    // Format: (+84) 0914259475
    return '($countryCode) $number';
  }

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('USER')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Không tìm thấy thông tin người dùng'));
        }

        // Lấy dữ liệu từ snapshot
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        
        // Trả về UI với dữ liệu trực tiếp từ userData
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: AppLocalizations.of(context).translate("Personal Information"),
            onBackPressed: () => Navigator.of(context).pop(),
            actions: [
              CustomIconButton(
                icon: Icons.edit,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditPersonInfoScreen())),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
              child: Column(
                children: [
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Full Name"),
                    text: userData['fullName'] ?? '',
                  ),
                  SizedBox(height: 16.h),
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Gender"),
                    text: _getDisplayValue(userData['gender'] ?? '', genderTranslations),
                  ),
                  SizedBox(height: 16.h),
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Identification Number"),
                    text: userData['citizenId'] ?? '',
                  ),
                  SizedBox(height: 16.h),
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Phone Number"),
                    text: _formatPhoneNumber(userData['phoneNumber'] ?? ''),
                  ),
                  SizedBox(height: 16.h),
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Address"),
                    text: userData['address'] ?? '',
                  ),
                  SizedBox(height: 16.h),
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Nationality"),
                    text: _getDisplayValue(userData['nationality'] ?? '', nationalityTranslations),
                  ),
                  SizedBox(height: 16.h),
                  DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Birthday"),
                    text: userData['birthday'] ?? '',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


