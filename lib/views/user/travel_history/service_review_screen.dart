import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
//import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/feedback_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/feedback_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';

final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

class ServiceReviewScreen extends StatelessWidget {
  final String licensePlate;

  const ServiceReviewScreen({
    required this.licensePlate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackViewModel(),
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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: Text(
                          licensePlate,
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
        body: Consumer<FeedbackViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        'assets/img/icon-cx3.png',
                        width: 335.w,
                        height: 188.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    const FeedbackForm(),
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
                            onPressed: () async {
                              final success = await viewModel.submitFeedback(
                                //feedbackId: DateTime.now().millisecondsSinceEpoch.toString(),
                                licensePlate: licensePlate,
                                userId: userId,
                              );

                              if (!success) {
                                if (viewModel.error.contains('độc hại')) {
                                  // Trường hợp toxic >= 90%
                                  await showAppDialog(
                                    context: context,
                                    title: AppLocalizations.of(context).translate("Warning"),
                                    content: viewModel.error,
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: Colors.orange,
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context).translate("OK")),
                                      ),
                                    ],
                                  );
                                } else if (viewModel.error.contains('có thể chứa nội dung không phù hợp')) {
                                  // Trường hợp toxic < 90%, cho phép xác nhận gửi
                                  final confirmed = await showAppDialog<bool>(
                                    context: context,
                                    title: AppLocalizations.of(context).translate("Warning"),
                                    content: viewModel.error,
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: Colors.orange,
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text(AppLocalizations.of(context).translate("Cancel")),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(AppLocalizations.of(context).translate("Submit")),
                                      ),
                                    ],
                                  );
                                  if (confirmed == true) {
                                    // Gửi lại comment không cần kiểm tra lại
                                    await viewModel.submitFeedback(
                                      //feedbackId: DateTime.now().millisecondsSinceEpoch.toString(),
                                      licensePlate: licensePlate,
                                      userId: userId
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)
                                            .translate("Thank you for your review")),
                                      ),
                                    );
                                  }
                                } else {
                                  // Các lỗi khác (comment trống, lỗi hệ thống...)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(viewModel.error),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // non_toxic hoặc gửi thành công không có vấn đề
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)
                                        .translate("Thank you for your review")),
                                  ),
                                );
                              }
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
            );
          },
        ),
      ),
    );
  }
}
