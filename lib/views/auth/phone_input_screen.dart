import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';
import 'package:tourguideapp/views/auth/otp_verification_screen.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class PhoneInputScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const PhoneInputScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
  }) : super(key: key);

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final String initialCountry = 'VN';
  PhoneNumber? _phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 88.h, 20.w, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).translate('Enter your phone number'),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  _phoneNumber = number;
                },
                onInputValidated: (bool value) {
                  print(value);
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: PhoneNumber(isoCode: initialCountry),
                textFieldController: _phoneController,
                formatInput: true,
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                inputDecoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context).translate('Phone number'),
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16.sp,
                  ),
                ),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () async {
                final signupViewModel = context.read<SignupViewModel>();
                
                if (_phoneNumber != null) {
                  // Ensure the phone number is in E.164 format
                  String phoneNumber = _phoneNumber!.phoneNumber ?? '';
                  if (!phoneNumber.startsWith('+')) {
                    phoneNumber = '+$phoneNumber';
                  }
                  
                  bool sent = await signupViewModel.sendPhoneVerification(phoneNumber);
                  if (sent && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OTPVerificationScreen(
                          email: widget.email,
                          password: widget.password,
                          username: widget.username,
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(signupViewModel.errorMessage ?? 'Failed to send verification code'),
                        backgroundColor: Colors.red,
                      ),
                    );
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
    );
  }
} 