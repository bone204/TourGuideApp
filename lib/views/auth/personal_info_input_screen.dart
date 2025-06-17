import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/views/auth/capture_id_card_screen.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class PersonalInfoInputScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final String phoneNumber;

  const PersonalInfoInputScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PersonalInfoInputScreen> createState() => _PersonalInfoInputScreenState();
}

class _PersonalInfoInputScreenState extends State<PersonalInfoInputScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context).translate('Please scan your ID card to continue'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32.h),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.document_scanner,
                        size: 80.w,
                        color: const Color(0xFF007BFF),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(context).translate('Scan your ID card to automatically fill in your information'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CaptureIdCardScreen(
                                        email: widget.email,
                                        password: widget.password,
                                        username: widget.username,
                                        phoneNumber: widget.phoneNumber,
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                        icon: const Icon(Icons.document_scanner, color: AppColors.white,),
                        label: Text(
                          AppLocalizations.of(context).translate('Scan ID Card'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          minimumSize: Size(double.infinity, 52.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
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