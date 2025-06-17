import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import 'package:tourguideapp/views/auth/hobbies_selection_screen.dart';

class IdCardConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> idCardData;
  final String email;
  final String password;
  final String username;
  final String phoneNumber;

  const IdCardConfirmationScreen({
    super.key,
    required this.idCardData,
    required this.email,
    required this.password,
    required this.username,
    required this.phoneNumber,
  });

  @override
  State<IdCardConfirmationScreen> createState() => _IdCardConfirmationScreenState();
}

class _IdCardConfirmationScreenState extends State<IdCardConfirmationScreen> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HobbiesSelectionScreen(
            email: widget.email,
            password: widget.password,
            username: widget.username,
            phoneNumber: widget.phoneNumber,
            fullName: widget.idCardData['name'] ?? '',
            gender: widget.idCardData['sex'] ?? '',
            nationality: widget.idCardData['nationality'] ?? '',
            birthday: widget.idCardData['dob'] ?? '',
            address: widget.idCardData['address'] ?? '',
            citizenId: widget.idCardData['id'] ?? '',
          ),
        ),
      );
    } catch (e) {
      print('Lỗi xử lý thông tin: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Confirm Information"),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Full Name"),
                text: widget.idCardData['name'] ?? '',
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("ID Number"),
                text: widget.idCardData['id'] ?? '',
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Date of Birth"),
                text: widget.idCardData['dob'] ?? '',
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Gender"),
                text: widget.idCardData['sex'] ?? '',
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Address"),
                text: widget.idCardData['address'] ?? '',
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate("Nationality"),
                text: widget.idCardData['nationality'] ?? '',
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate("Cancel"),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).translate("Continue"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 