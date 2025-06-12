import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/views/my_vehicle/banking_information_screen.dart';
import 'package:tourguideapp/views/my_vehicle/vehicle_register_screen.dart';
import 'package:tourguideapp/views/my_vehicle/vehicle_rental_register_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';
import 'package:tourguideapp/widgets/rental_vehicle_card.dart';

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

    return Consumer2<ContractViewModel, RentalVehicleViewModel>(
      builder: (context, contractViewModel, rentalVehicleViewModel, child) {
        final locale = Localizations.localeOf(context).languageCode;
        
        if (contractViewModel.contracts.isEmpty) {
          return _buildRegisterView();
        }

        final contractStatus = contractViewModel.contracts.first.contractStatus;
        final displayStatus = contractViewModel.getDisplayContractStatus(contractStatus, locale);
        
        if (displayStatus == (locale == 'vi' ? 'Chờ duyệt' : 'Pending Approval')) {
          return _buildPendingApprovalView();
        }

        if (displayStatus == (locale == 'vi' ? 'Đã duyệt' : 'Approved')) {
          // Kiểm tra trạng thái của xe
          if (rentalVehicleViewModel.vehicles.isEmpty) {
            return _buildAddCarView();
          }

          // Hiển thị vehicle card bất kể trạng thái xe
          return _buildVehicleView();
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
                fontWeight: FontWeight.w700,
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
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.black),
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
                            "${AppLocalizations.of(context).translate('Registrant')}: $fullName",
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
                                style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w700),
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
                fontWeight: FontWeight.w700,
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

  Widget _buildVehicleView() {
    return Consumer<RentalVehicleViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Column(
              children: [
                // Hiển thị danh sách các xe
                ...viewModel.vehicles.map((vehicle) => 
                  RentalVehicleCard(vehicle: vehicle)
                ).toList(),
                
                // Thêm nút Add Vehicle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: CustomElevatedButton(
                    text: "Add Vehicle",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleRegisterScreen()
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate("Chat Screen"),
          actions: [
            CustomIconButton(
              icon: Icons.info_rounded,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BankingInformationScreen()));
              },
            ),
          ],
        ),
      body: _buildBody(),
    );
  }
}


