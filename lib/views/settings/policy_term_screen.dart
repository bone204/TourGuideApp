import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
// import 'package:tourguideapp/widgets/interactive_row_widget.dart';
import '../../widgets/custom_icon_button.dart';

class PolicyAndTermScreen extends StatefulWidget {
  const PolicyAndTermScreen({super.key});

  @override
  _PolicyAndTermScreenScreenState createState() => _PolicyAndTermScreenScreenState();
}

class _PolicyAndTermScreenScreenState extends State<PolicyAndTermScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h), // Chiều cao app bar
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).translate('Policies & Terms'),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp, // Kích thước chữ sử dụng ScreenUtil
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 84.w),
                      ],
                    );
                  },
                ),
              ]
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h), // Padding sử dụng ScreenUtil
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).translate(''),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp, // Kích thước chữ sử dụng ScreenUtil
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
