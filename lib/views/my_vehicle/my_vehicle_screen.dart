import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/views/my_vehicle/vehicle_rental_register_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  _MyVehicleScreenState createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  String? _contractStatus;

  @override
  void initState() {
    super.initState();
    _loadContractStatus();
  }

  Future<void> _loadContractStatus() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUserId;

    if (currentUserId != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('CONTRACT')
            .where('userId', isEqualTo: currentUserId)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          setState(() {
            _contractStatus = doc['contractStatus'] as String?;
          });
          if (kDebugMode) {
            print("Trạng thái hợp đồng: $_contractStatus");
          }
        } else {
          setState(() {
            _contractStatus = null;
          });
          if (kDebugMode) {
            print("Không tìm thấy hợp đồng cho userId: $currentUserId");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi khi truy vấn hợp đồng từ Firestore: $e");
        }
        setState(() {
          _contractStatus = null;
        });
      }
    } else {
      setState(() {
        _contractStatus = null;
      });
      if (kDebugMode) {
        print("currentUserId là null");
      }
    }
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

  Widget _buildBody() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUserId;

    if (currentUserId == null) {
        return _buildRegisterView();
    }

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('CONTRACT')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
                return const Center(child: Text('Lỗi khi tải dữ liệu'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildRegisterView();
            }

            final doc = snapshot.data!.docs.first;
            final contractStatus = doc['contractStatus'] as String?;

            if (kDebugMode) {
                print("Trạng thái hợp đồng: $contractStatus");
            }

            if (contractStatus == 'Pending Approval') {
                return _buildPendingApprovalView();
            }

            if (contractStatus == 'Approved') {
                return _buildAddCarView();
            }

            return Container();
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
                    _contractStatus = 'Pending Approval';
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
    return Center(
      child: Text(
        "Đang đăng ký...",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
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
              onPressed: () {
                // Logic để thêm xe mới
                // Ví dụ: Navigator.push đến màn hình thêm xe
              },
            ),
          ],
        ),
      ),
    );
  }
}


