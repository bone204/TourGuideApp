import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/login_viewmodel.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tourguideapp/views/auth/reset_password_screen.dart';

class ForgotPasswordOTPScreen extends StatelessWidget {
  final String phoneNumber;

  const ForgotPasswordOTPScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

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
                    text: 'We sent you a 6-digit code to ',
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
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) {},
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
                final loginViewModel = context.read<LoginViewModel>();
                bool verified = await loginViewModel.verifyPasswordResetOTP(value);
                if (verified && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordScreen(
                        phoneNumber: phoneNumber,
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final loginViewModel = context.read<LoginViewModel>();
                    await loginViewModel.sendPasswordResetOTP(phoneNumber);
                  },
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