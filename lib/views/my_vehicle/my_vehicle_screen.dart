import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/my_vehicle/vehicle_rental_register_screen.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';


class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  _MyVehicleScreenState createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  bool _isRegistered = false;

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
        body: SingleChildScrollView(
          child: Padding(
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
                  if (!_isRegistered)
                    CustomElevatedButton(
                      text: "Register now",
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VehicleRentalRegisterScreen()),
                        );

                        if (result == true) {
                          setState(() {
                            _isRegistered = true;
                          });
                        }
                      },
                    ),
                  if (_isRegistered)
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
          ),
        )
      ),
    );
  }
}


