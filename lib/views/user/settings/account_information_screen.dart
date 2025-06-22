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
import '../../../widgets/app_dialog.dart';

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
                  String newName = accountInfoViewModel.name;
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context).translate('Edit Account Information')),
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
                          controller: TextEditingController(text: newName),
                          onChanged: (value) => newName = value,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).translate('Username'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context).translate('Cancel'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (newName.isNotEmpty) {
                            accountInfoViewModel.updateName(newName);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h), // Padding sử dụng ScreenUtil
        child: Align(
          alignment: Alignment.topCenter,
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
    );
  }

  Future<void> _showSaveConfirmDialog(BuildContext context) async {
    await showAppDialog(
      context: context,
      title: AppLocalizations.of(context).translate('Thông báo'),
      content: AppLocalizations.of(context).translate('Bạn có chắc chắn muốn lưu thay đổi?'),
      icon: Icons.info_outline,
      iconColor: Theme.of(context).primaryColor,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).translate('Huỷ')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context).translate('Lưu')),
        ),
      ],
    );
  }
}
