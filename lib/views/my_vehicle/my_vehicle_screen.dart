import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/views/my_vehicle/vehicle_register_screen.dart';
import 'package:tourguideapp/views/my_vehicle/vehicle_rental_register_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  _MyVehicleScreenState createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildBody() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUid = authViewModel.currentUserId;

    if (currentUid == null) {
      return _buildRegisterView();
    }

    return Consumer<ContractViewModel>(
      builder: (context, contractViewModel, child) {
        if (contractViewModel.contracts.isEmpty) {
          return _buildRegisterView();
        }

        final contractStatus = contractViewModel.contracts.first.contractStatus;

        if (contractStatus == 'Pending Approval') {
          return _buildPendingApprovalView();
        }

        if (contractStatus == 'Approved') {
          return _buildAddCarView();
        }

        return _buildRegisterView();
      },
    );
  }

  Widget _buildRegisterView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 100.h),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            ClipRRect(
              child: Image.asset(
                'assets/img/my_vehicle_1.png',
                height: 192.h,
                width: 192.w,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).translate("You haven't registered any vehicles yet."),
              style: TextStyle(
                color: const Color(0xFF6C6C6C),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            CustomElevatedButton(
              text: "Register now",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleRentalRegisterScreen()),
                );

                if (result == true) {
                  setState(() {
                    // _contractStatus = 'Pending Approval';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalView() {
    return Consumer<ContractViewModel>(
      builder: (context, contractViewModel, child) {
        return FutureBuilder<String>(
          future: contractViewModel.getUserFullName(contractViewModel.contracts.first.userId),
          builder: (context, snapshot) {
            final fullName = snapshot.data ?? 'Unknown';
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              height: 140.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        'assets/img/pending_approval.png',
                        height: 116.h,
                        width: 116.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Vehicle Rental Register"),
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(Icons.calendar_month, size: 16.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "26/11/2024",
                                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Registrant: $fullName",
                            style: TextStyle(fontSize: 12.sp, color: AppColors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            width: double.infinity,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).translate("Pending Approval"),
                                style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddCarView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 100.h),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            ClipRRect(
              child: Image.asset(
                'assets/img/my_vehicle_1.png',
                height: 192.h,
                width: 192.w,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).translate("You haven't added any cars yet."),
              style: TextStyle(
                color: const Color(0xFF6C6C6C),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            CustomElevatedButton(
              text: "Add Vehicle",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleRegisterScreen()),
                );

                if (result == true) {
                  setState(() {
                    // _contractStatus = 'Pending Approval';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil
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
                          AppLocalizations.of(context).translate('My Vehicle'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }
}


