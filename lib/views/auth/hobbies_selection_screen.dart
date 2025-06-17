import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';
import 'package:tourguideapp/widgets/wave_card.dart';

class HobbiesSelectionScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final String phoneNumber;
  final String fullName;
  final String gender;
  final String nationality;
  final String birthday;
  final String citizenId;
  final String address;

  const HobbiesSelectionScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
    required this.phoneNumber,
    required this.fullName,
    required this.gender,
    required this.nationality,
    required this.birthday,
    required this.address,
    required this.citizenId
  }) : super(key: key);

  @override
  State<HobbiesSelectionScreen> createState() => _HobbiesSelectionScreenState();
}

class _HobbiesSelectionScreenState extends State<HobbiesSelectionScreen> {
  bool _isLoading = false;
  Map<String, bool> selectedCategories = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    
    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              const WaveCard(
                height: 400,
                color: Color(0xFF66B2FF),
              ),
              SafeArea(
                child: Consumer<SignupViewModel>(
                  builder: (context, signupViewModel, child) {
                    if (signupViewModel.isCategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (signupViewModel.categories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No categories found',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () => signupViewModel.fetchCategories(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(top: 60.h, left: 20.w, right: 20.w, bottom: 60.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('What fascinates you?'),
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            AppLocalizations.of(context).translate('To give you a personalized experience,\nlet us know your interests.'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.only(bottom: 32.h),
                              children: [
                                for (int i = 0; i < signupViewModel.categories.length; i += 2)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: Row(
                                      children: [
                                        for (int j = i; j < min(i + 2, signupViewModel.categories.length); j++)
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: j.isOdd ? 6.w : 0,
                                                right: j.isEven ? 6.w : 0,
                                              ),
                                              child: Builder(
                                                builder: (context) {
                                                  final category = signupViewModel.categories[j];
                                                  final isSelected = selectedCategories[category.categoryId] ?? false;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedCategories[category.categoryId] = !isSelected;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 10.w,
                                                        vertical: 16.h,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected ? AppColors.primaryColor : AppColors.white,
                                                        borderRadius: BorderRadius.circular(8.r),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.25),
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        category.getTranslatedName(currentLocale),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: isSelected ? AppColors.white : AppColors.primaryColor,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () async {
                                final selectedCategoryIds = selectedCategories.entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .toList();

                                if (selectedCategoryIds.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context).translate('Please select at least one interest')
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  final signupViewModel = context.read<SignupViewModel>();
                                  final user = await signupViewModel.signUp(
                                    widget.email,
                                    widget.password,
                                    widget.username,
                                    widget.fullName,
                                    widget.citizenId,
                                    widget.gender,
                                    widget.address,
                                    widget.phoneNumber,
                                    widget.nationality,
                                    widget.birthday,
                                    selectedCategoryIds,
                                  );

                                  if (!mounted) return;

                                  if (user != null) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/home',
                                      (route) => false,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context).translate('Registration failed')
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007BFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                AppLocalizations.of(context).translate('Get Started'),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
} 