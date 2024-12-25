import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';

class OTPVerificationScreen extends StatelessWidget {
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

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String _getOTP() {
    return _controllers.map((controller) => controller.text).join();
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Verification Code',
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
                  const TextSpan(
                    text: 'We sent you a 6-digit code (OTP) to your phone number ',
                  ),
                  TextSpan(
                    text: phoneNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Container(
                  width: 45.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _controllers[index].text.length > 0 
                          ? const Color(0xFF007BFF)
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () async {
                final signupViewModel = context.read<SignupViewModel>();
                final otp = _getOTP();
                
                if (otp.length == 6) {
                  bool verified = await signupViewModel.verifyOTP(otp);
                  if (verified) {
                    final user = await signupViewModel.signUp(
                      email,
                      password,
                      username,
                      '', // fullName
                      '', // address
                      '', // gender
                      '', // citizenId
                      phoneNumber,
                      '', // nationality
                      '', // birthday
                    );
                    
                    if (user != null && context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Verify',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't Receive the Code? ",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final signupViewModel = context.read<SignupViewModel>();
                    await signupViewModel.sendPhoneVerification(phoneNumber);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Resend',
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
    );
  }
} 