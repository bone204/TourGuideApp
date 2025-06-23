import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import '../../../viewmodels/accountInfo_viewmodel.dart';
import '../../../widgets/custom_icon_button.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final accountInfoViewModel = Provider.of<AccountInfoViewModel>(context);
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('Account Information'),
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          CustomIconButton(
            icon: Icons.edit,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController nameController = TextEditingController(text: accountInfoViewModel.name);
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                        titlePadding: EdgeInsets.only(top: 24.h, left: 24.w, right: 24.w, bottom: 0),
                        title: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(accountInfoViewModel.avatar),
                              onBackgroundImageError: (exception, stackTrace) {
                                // fallback
                              },
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              AppLocalizations.of(context).translate('Edit Account Information'),
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AppLocalizations.of(context).translate('Update your username below'),
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('Username'),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: nameController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).translate('Username'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        actionsPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context).translate('Cancel'),
                              style: TextStyle(color: Colors.grey[600], fontSize: 15.sp),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: nameController.text.trim().isNotEmpty
                                ? () {
                                    accountInfoViewModel.updateName(nameController.text.trim());
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            ),
                            child: Text(
                              AppLocalizations.of(context).translate('Save'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h), // Padding sử dụng ScreenUtil
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        accountInfoViewModel.avatar,
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Fallback nếu load ảnh thất bại
                        const AssetImage('assets/img/bg_route_1.png');
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.photo_camera),
                                        title: Text(AppLocalizations.of(context).translate('Take Photo')),
                                        onTap: () {
                                          Navigator.pop(context);
                                          accountInfoViewModel.changeProfileImage(ImageSource.camera);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: Text(AppLocalizations.of(context).translate('Choose from Gallery')),
                                        onTap: () {
                                          Navigator.pop(context);
                                          accountInfoViewModel.changeProfileImage(ImageSource.gallery);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  accountInfoViewModel.name,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 40.h),
                DisabledTextField(
                  labelText: AppLocalizations.of(context).translate('Username'),
                  text: accountInfoViewModel.name
                ),
                SizedBox(height: 16.h),
                DisabledTextField(
                  labelText: AppLocalizations.of(context).translate('Email'),
                  text: accountInfoViewModel.email
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
