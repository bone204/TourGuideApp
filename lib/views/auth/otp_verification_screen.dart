import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';
import 'package:tourguideapp/views/auth/personal_info_input_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final String phoneNumber;

  OTPVerificationScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {


  bool isVerifying = false;

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  AppLocalizations.of(context).translate('Verification Code'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context).translate('We sent you a 6-digit code (OTP) to your phone number '),
                      ),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  enabled: !isVerifying,
                  onChanged: (value) {
                    // Không cần xử lý gì ở đây
                  },
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 56.h,
                    fieldWidth: 45.w,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: const Color(0xFF007BFF),
                    inactiveColor: Colors.grey[300]!,
                    selectedColor: const Color(0xFF007BFF),
                  ),
                  enableActiveFill: true,
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  onCompleted: (value) async {
                    // Thêm loading indicator khi đang verify
                    setState(() {
                      isVerifying = true;
                    });

                    try {
                      final signupViewModel = context.read<SignupViewModel>();
                      bool verified = await signupViewModel.verifyOTP(value);
                      
                      if (verified && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalInfoScreen(
                              email: widget.email,
                              password: widget.password,
                              username: widget.username,
                              phoneNumber: widget.phoneNumber,
                            ),
                          ),
                        );
                      } else {
                        // Hiển thị thông báo lỗi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).translate('Invalid verification code')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isVerifying = false;
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("Didn't Receive the Code? "),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final signupViewModel = context.read<SignupViewModel>();
                        await signupViewModel.sendPhoneVerification(widget.phoneNumber);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('Resend'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF007BFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (isVerifying) _buildLoadingOverlay(),
        ],
      ),
    );
  }
} 