import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/settings/edit_personal_information_screen.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import '../../widgets/custom_icon_button.dart';
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
                              icon: Icons.edit,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditPersonInfoScreen(),
                                  ),
                                );
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
                      text: userData['gender'] ?? '',
                    ),
                    SizedBox(height: 16.h),
                    DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Identification Number"),
                      text: userData['citizenId'] ?? '',
                    ),
                    SizedBox(height: 16.h),
                    DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Phone Number"),
                      text: userData['phoneNumber'] ?? '',
                    ),
                    SizedBox(height: 16.h),
                    DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Address"),
                      text: userData['address'] ?? '',
                    ),
                    SizedBox(height: 16.h),
                    DisabledTextField(
                      labelText: AppLocalizations.of(context).translate("Nationality"),
                      text: userData['nationality'] ?? '',
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
          ),
        );
      },
    );
  }
}


