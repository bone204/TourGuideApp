import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/color/colors.dart';

class BusTicketDetail extends StatefulWidget {
  @override
  _BusTicketDetailState createState() => _BusTicketDetailState();
}

class _BusTicketDetailState extends State<BusTicketDetail> {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false, false];
  
  String _getStepTitle(int index, BuildContext context) {
    switch (index) {
      case 0:
        return AppLocalizations.of(context).translate("Choose Seats");
      case 1:
        return AppLocalizations.of(context).translate("Passenger Info");
      case 2:
        return AppLocalizations.of(context).translate("Pick-up/Drop");
      case 3:
        return AppLocalizations.of(context).translate("Payment");
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
  }


  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _stepCompleted[_currentStep] = true;
        _currentStep++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        
        if (_currentStep == 2) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _stepCompleted[_currentStep] = false;
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        
        if (_currentStep == 1) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Bus Ticket Detail',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Step indicators
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Row(
                      children: [
                        // Indicator button
                        Container(
                          width: 30.w,
                          height: 30.h,
                          decoration: BoxDecoration(
                            color: _currentStep >= index ? AppColors.primaryColor : Colors.transparent,
                            border: Border.all(
                              color: _currentStep >= index ? AppColors.primaryColor : Colors.grey,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: _currentStep >= index ? Colors.white : Colors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Title next to button
                        SizedBox(width: 8.w),
                        SizedBox(
                          child: Text(
                            _getStepTitle(index, context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.start,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        // Connecting line
                        if (index < 3)
                          Container(
                            width: 60.w,
                            height: 1.h,
                            color: _currentStep > index ? AppColors.primaryColor : Colors.grey,
                          ),
                          SizedBox(width: 20.w),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTicketInfoPage(),
                _buildPassengerInfoPage(),
                _buildPaymentPage(),
                _buildConfirmationPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF007BFF),
                        side: const BorderSide(color: Color(0xFF007BFF)),
                        minimumSize: Size(double.infinity, 50.h),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate("Previous"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0)
                  SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 3 ? () {
                      // Handle confirmation
                    } : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50.h),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      _currentStep == 3 ? AppLocalizations.of(context).translate("Confirm") : AppLocalizations.of(context).translate("Next"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket Information'),
            // Add your ticket info widgets
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger Information'),
            // Add your passenger info widgets
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment'),
            // Add your payment widgets
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirmation'),
            // Add your confirmation widgets
          ],
        ),
      ),
    );
  }
}