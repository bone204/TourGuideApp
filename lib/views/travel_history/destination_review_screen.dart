import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';

class DestinationReviewScreen extends StatelessWidget {
  final DestinationModel destination;

  const DestinationReviewScreen({
    required this.destination,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Text(
                        destination.destinationName,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
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
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  destination.photo.isNotEmpty ? destination.photo[0] : '',
                  width: 335.w,
                  height: 188.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context).translate("Rate")}:",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 30.w),
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 18.w),
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context).translate("Write your review"),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF007BFF),
                        side: const BorderSide(color: Color(0xFF007BFF)),
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate("Cancel"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement review submission
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate("Submit"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
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